@tool
extends CompositorEffect
class_name CompositorEffectApplySSSR

# This is the second effect that make up a very basic screen space
# reflection implementation.
#
# This is a multipart process
# Step 1: Create a reflection texture
# Step 2: Create mipmaps of our reflection texture
# Step 3: Apply our reflection texture to our color buffer
#
# Note that we perform everything at half resolution.
# This is designed to only work on the Forward+ renderer.

@export var max_distance := 1.0
@export_range(0, 64, 1) var max_steps := 32

func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_SKY
	needs_normal_roughness = true
	needs_separate_specular = true
	RenderingServer.call_on_render_thread(_initialize_compute)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# When this is called it should be safe to clean up our shader.
		# If not we'll crash anyway because we can no longer call our _render_callback.
		if nearest_sampler.is_valid():
			rd.free_rid(nearest_sampler)
		if linear_sampler.is_valid():
			rd.free_rid(linear_sampler)
		if reflection_shader.is_valid():
			rd.free_rid(reflection_shader)
		if overlay_shader.is_valid():
			rd.free_rid(overlay_shader)

###############################################################################
# Everything after this point is designed to run on our rendering thread

var rd: RenderingDevice

var nearest_sampler: RID
var linear_sampler: RID

var reflection_shader: RID
var reflection_pipeline: RID

var overlay_shader: RID
var overlay_pipeline: RID

func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		OS.alert("RenderingDevice is not available, aborting.\nCompositor effects require RenderingDevice to be available, which means you have to use the Forward+ or Mobile rendering method.")
		return

	# Create our samplers
	var sampler_state := RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	nearest_sampler = rd.sampler_create(sampler_state)

	sampler_state = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = rd.sampler_create(sampler_state)

	# Create our reflection shader and pipeline
	var shader_file := load("res://simple_ssr/reflect_sssr.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	reflection_shader = rd.shader_create_from_spirv(shader_spirv)
	reflection_pipeline = rd.compute_pipeline_create(reflection_shader)

	# Create our overlay shader
	shader_file = load("res://simple_ssr/overlay_sssr.glsl")
	shader_spirv = shader_file.get_spirv()
	overlay_shader = rd.shader_create_from_spirv(shader_spirv)


func _render_callback(p_effect_callback_type: int, p_render_data: RenderData) -> void:
	if rd and p_effect_callback_type == CompositorEffect.EFFECT_CALLBACK_TYPE_POST_SKY:
		# Get our render scene buffers object, this gives us access to our render buffers.
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers: RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
		var render_scene_data := p_render_data.get_render_scene_data()
		if render_scene_buffers and render_scene_data:
			# Get our render size. This is the 3D render resolution (which can be affected by the
			# `scaling_3d_scale` property), not the window size.
			var render_size := render_scene_buffers.get_internal_size()
			if render_size.x <= 1 and render_size.y <= 1:
				return

			@warning_ignore("integer_division")
			var half_size := Vector2i((render_size.x + 1) / 2, (render_size.y + 1) / 2)

			# We can use a compute shader here.
			@warning_ignore("integer_division")
			var x_groups := (half_size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (half_size.y - 1) / 8 + 1

			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count := render_scene_buffers.get_view_count()
			for view in view_count:
				# Get the RID for our color image. We will be reading from and writing to it.
				var color_image := render_scene_buffers.get_color_layer(view)
				var normal_image: RID = render_scene_buffers.get_texture_slice("forward_clustered", "normal_roughness", view, 0, 1, 1)

				if !render_scene_buffers.has_texture("SSSR", "reflection"):
					var usage_bits := RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
					# May increase this if we want blurred reflections.
					var mipmaps := 1
					render_scene_buffers.create_texture("SSSR", "reflection", RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM, usage_bits, RenderingDevice.TEXTURE_SAMPLES_1, half_size, 1, mipmaps, true)

				var depth_mips: RID = render_scene_buffers.get_texture_slice("SSSR", "depth_mips", 0, 0, 1, 4)
				var reflection: RID = render_scene_buffers.get_texture_slice("SSSR", "reflection", 0, 0, 1, 1)

				var projection := render_scene_data.get_view_projection(view)
				var eye_offset := render_scene_data.get_view_eye_offset(view)

				###################################################################################
				# Step 2, generate reflection map

				# We don't have structures (yet) so we need to build our push constant
				# "the hard way"...
				var push_constant := PackedFloat32Array()
				var ipx := projection.x
				var ipy := projection.y
				var ipz := projection.z
				var ipw := projection.w
				push_constant.push_back(ipx.x)
				push_constant.push_back(ipx.y)
				push_constant.push_back(ipx.z)
				push_constant.push_back(ipx.w)
				push_constant.push_back(ipy.x)
				push_constant.push_back(ipy.y)
				push_constant.push_back(ipy.z)
				push_constant.push_back(ipy.w)
				push_constant.push_back(ipz.x)
				push_constant.push_back(ipz.y)
				push_constant.push_back(ipz.z)
				push_constant.push_back(ipz.w)
				push_constant.push_back(ipw.x)
				push_constant.push_back(ipw.y)
				push_constant.push_back(ipw.z)
				push_constant.push_back(ipw.w)
				push_constant.push_back(eye_offset.x)
				push_constant.push_back(eye_offset.y)
				push_constant.push_back(eye_offset.z)
				push_constant.push_back(0.0)
				push_constant.push_back(half_size.x)
				push_constant.push_back(half_size.y)
				push_constant.push_back(max_distance)
				push_constant.push_back(max_steps)

				# Create uniform sets. This will be cached: the cache will be cleared if our viewport's configuration is changed.

				var uniform := RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform.binding = 0
				uniform.add_id(nearest_sampler)
				uniform.add_id(depth_mips)
				var depth_set := UniformSetCacheRD.get_cache(reflection_shader, 0, [uniform])

				uniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform.binding = 0
				uniform.add_id(nearest_sampler)
				uniform.add_id(normal_image)
				var normal_set := UniformSetCacheRD.get_cache(reflection_shader, 1, [uniform])

				uniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform.binding = 0
				uniform.add_id(linear_sampler)
				uniform.add_id(color_image)
				var color_set := UniformSetCacheRD.get_cache(reflection_shader, 2, [uniform])

				uniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(reflection)
				var reflect_set := UniformSetCacheRD.get_cache(reflection_shader, 3, [uniform])

				rd.draw_command_begin_label("Stochastic SSR", Color(1.0, 1.0, 1.0, 1.0))

				# Run our compute shader
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, reflection_pipeline)
				rd.compute_list_bind_uniform_set(compute_list, depth_set, 0)
				rd.compute_list_bind_uniform_set(compute_list, normal_set, 1)
				rd.compute_list_bind_uniform_set(compute_list, color_set, 2)
				rd.compute_list_bind_uniform_set(compute_list, reflect_set, 3)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
				rd.compute_list_end()

				###################################################################################
				# Step 3, generate reflection mips

				# TODO

				###################################################################################
				# Step 4, overlay reflections

				# Get our framebuffer
				var fb: RID = FramebufferCacheRD.get_cache_multipass([color_image], [], 1)
				var fb_format := rd.framebuffer_get_format(fb)

				# Now need access to our reflection image but with a sampler
				uniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform.binding = 0
				uniform.add_id(linear_sampler)
				uniform.add_id(reflection)
				reflect_set = UniformSetCacheRD.get_cache(overlay_shader, 0, [ uniform ])

				# Check our pipeline
				if not overlay_pipeline.is_valid():
					var prs := RDPipelineRasterizationState.new()
					var pms := RDPipelineMultisampleState.new()
					var pdss := RDPipelineDepthStencilState.new()
					var pcbs := RDPipelineColorBlendState.new()
					var attachment := RDPipelineColorBlendStateAttachment.new()
					attachment.enable_blend = true
					attachment.alpha_blend_op = RenderingDevice.BLEND_OP_ADD
					attachment.color_blend_op = RenderingDevice.BLEND_OP_ADD
					attachment.src_color_blend_factor = RenderingDevice.BLEND_FACTOR_SRC_ALPHA
					attachment.dst_color_blend_factor = RenderingDevice.BLEND_FACTOR_ONE
					attachment.src_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_SRC_ALPHA
					attachment.dst_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_ONE
					pcbs.attachments = [attachment]

					overlay_pipeline = rd.render_pipeline_create(overlay_shader, fb_format, RenderingDevice.INVALID_FORMAT_ID, RenderingDevice.RENDER_PRIMITIVE_TRIANGLES, prs, pms, pdss, pcbs)

				var clear_colors := PackedColorArray()
				var draw_list := rd.draw_list_begin(fb, RenderingDevice.INITIAL_ACTION_KEEP, RenderingDevice.FINAL_ACTION_READ, RenderingDevice.INITIAL_ACTION_KEEP, RenderingDevice.FINAL_ACTION_READ, clear_colors);

				rd.draw_list_bind_render_pipeline(draw_list, overlay_pipeline)
				# We can reuse `reflect_set` here.
				rd.draw_list_bind_uniform_set(draw_list, reflect_set, 0)
				# rd.draw_list_set_push_constant(draw_list, raster_push_constant, raster_push_constant.size())
				rd.draw_list_draw(draw_list, false, 1, 3)

				rd.draw_list_end()

				rd.draw_command_end_label()
