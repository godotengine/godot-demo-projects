@tool
extends RenderingEffect
class_name RenderingEffectGrayScale

# This is a very simple effects demo that takes our color values and writes
# back gray scale values. 

func _init():
	effect_callback_type = RenderingEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
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
	var shader_file = load("res://gray_scale/gray_scale.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)

func _render_callback(p_effect_callback_type, p_render_data):
	if rd and p_effect_callback_type == RenderingEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT:
		# Get our render scene buffers object, this gives us access to our render buffers. 
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers : RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# Get our render size, this is the 3D render resolution!
			var size = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# We can use a compute shader here 
			var x_groups = (size.x - 1) / 8 + 1
			var y_groups = (size.y - 1) / 8 + 1

			# Barrier
			rd.barrier(RenderingDevice.BARRIER_MASK_ALL_BARRIERS, RenderingDevice.BARRIER_MASK_COMPUTE)

			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count = render_scene_buffers.get_view_count()
			for view in range(view_count):
				# Get the RID for our color image, we will be reading from and writing to it.
				var input_image = render_scene_buffers.get_color_layer(view)

				# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed
				var uniform : RDUniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(input_image)
				var uniform_set = UniformSetCacheRD.get_cache(shader, 0, [ uniform ])

				# Run our compute shader
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
				rd.compute_list_end()
