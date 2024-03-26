@tool
extends RenderingEffect
class_name RenderingEffectCreateDepthMips

# This is one of our two effects that make up a very basic screen space
# reflection implementation.
#
# This first stage runs right after creating our pre-depth pass and
# generates mip levels of our depth data using a minimum value filter.
#
# Note that we perform everything at half resolution.
# This is designed to only work on the Forward+ renderer.

func _init():
	effect_callback_type = RenderingEffect.EFFECT_CALLBACK_TYPE_PRE_OPAQUE
	access_resolved_depth = true
	RenderingServer.call_on_render_thread(_initialize_compute)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# When this is called it should be safe to clean up our shader.
		# If not we'll crash anyway because we can no longer call our _render_callback.
		if shader.is_valid():
			rd.free_rid(shader)

###############################################################################
# Everything after this point is designed to run on our rendering thread

var rd : RenderingDevice

var shader : RID
var pipeline : RID

func _initialize_compute():
	rd = RenderingServer.get_rendering_device()
	if !rd:
		return

	# Create our shader
	var shader_file = load("res://simple_ssr/create_depth_mips.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)

func _render_callback(p_effect_callback_type, p_render_data):
	if rd and p_effect_callback_type == RenderingEffect.EFFECT_CALLBACK_TYPE_PRE_OPAQUE:
		# Get our render scene buffers object, this gives us access to our render buffers. 
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers : RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# Get our render size, this is the 3D render resolution!
			var render_size = render_scene_buffers.get_internal_size()
			if render_size.x <= 1 and render_size.y <= 1:
				return

			var half_size = Vector2i((render_size.x + 1) / 2, (render_size.y + 1) / 2)

			# We can use a compute shader here 
			var x_groups = (half_size.x - 1) / 8 + 1
			var y_groups = (half_size.y - 1) / 8 + 1

			# Barrier
			rd.barrier(RenderingDevice.BARRIER_MASK_ALL_BARRIERS, RenderingDevice.BARRIER_MASK_COMPUTE)

			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count = render_scene_buffers.get_view_count()
			for view in range(view_count):
				# Get the RID for our depth image, we will be reading from it.
				var input_image = render_scene_buffers.get_texture_slice("render_buffers", "depth", 0, 0, 1, 1)

				# Make sure our output image exists
				if !render_scene_buffers.has_texture("SSSR", "depth_mips"):
					var usage_bits : int = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
					render_scene_buffers.create_texture("SSSR", "depth_mips", RenderingDevice.DATA_FORMAT_R32_SFLOAT, usage_bits, RenderingDevice.TEXTURE_SAMPLES_1, half_size, 1, 4, true)

				# We don't have structures (yet) so we need to build our push constant
				# "the hard way"...
				var push_constant : PackedFloat32Array = PackedFloat32Array()
				push_constant.push_back(render_size.x)
				push_constant.push_back(render_size.y)
				push_constant.push_back(half_size.x)
				push_constant.push_back(half_size.y)

				# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed
				var depth_image_uniform : RDUniform = RDUniform.new()
				depth_image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				depth_image_uniform.binding = 0
				depth_image_uniform.add_id(input_image)

				var uniform_set = UniformSetCacheRD.get_cache(shader, 0, [ depth_image_uniform ])

				var depth_mip1_uniform : RDUniform = RDUniform.new()
				depth_mip1_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				depth_mip1_uniform.binding = 0
				depth_mip1_uniform.add_id(render_scene_buffers.get_texture_slice("SSSR", "depth_mips", 0, 0, 1, 1))

				var depth_mip2_uniform : RDUniform = RDUniform.new()
				depth_mip2_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				depth_mip2_uniform.binding = 1
				depth_mip2_uniform.add_id(render_scene_buffers.get_texture_slice("SSSR", "depth_mips", 0, 1, 1, 1))

				var depth_mip3_uniform : RDUniform = RDUniform.new()
				depth_mip3_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				depth_mip3_uniform.binding = 2
				depth_mip3_uniform.add_id(render_scene_buffers.get_texture_slice("SSSR", "depth_mips", 0, 2, 1, 1))

				var depth_mip4_uniform : RDUniform = RDUniform.new()
				depth_mip4_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				depth_mip4_uniform.binding = 3
				depth_mip4_uniform.add_id(render_scene_buffers.get_texture_slice("SSSR", "depth_mips", 0, 3, 1, 1))

				var depth_mips_set = UniformSetCacheRD.get_cache(shader, 1, [ depth_mip1_uniform, depth_mip2_uniform, depth_mip3_uniform, depth_mip4_uniform ])

				rd.draw_command_begin_label("Create depth mips", Color(1.0, 1.0, 1.0, 1.0))

				# Run our compute shader
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_bind_uniform_set(compute_list, depth_mips_set, 1)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
				rd.compute_list_end()

				rd.draw_command_end_label()

