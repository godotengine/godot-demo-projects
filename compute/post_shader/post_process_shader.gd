@tool
extends CompositorEffect
class_name PostProcessShader

const template_shader := """#version 450

#define MAX_VIEWS 2

#include "godot/scene_data_inc.glsl"

// Invocations in the (x, y, z) dimension.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) uniform SceneDataBlock {
	SceneData data;
	SceneData prev_data;
}
scene_data_block;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;
layout(set = 0, binding = 2) uniform sampler2D depth_texture;

// Our push constant.
// Must be aligned to 16 bytes, just like the push constant we passed from the script.
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float view;
	float pad;
} params;

// The code we want to execute in each invocation.
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	int view = int(params.view);

	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	vec2 uv_norm = vec2(uv) / params.raster_size;

	vec4 color = imageLoad(color_image, uv);
	float depth = texture(depth_texture, uv_norm).r;

	#COMPUTE_CODE

	imageStore(color_image, uv, color);
}"""

@export_multiline var shader_code := "":
	set(value):
		mutex.lock()
		shader_code = value
		shader_is_dirty = true
		mutex.unlock()

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var nearest_sampler : RID

var mutex := Mutex.new()
var shader_is_dirty := true


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()


# System notifications, we want to react on the notification that
# alerts us we are about to be destroyed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			# Freeing our shader will also free any dependents such as the pipeline!
			RenderingServer.free_rid(shader)
		if nearest_sampler.is_valid():
			rd.free_rid(nearest_sampler)


#region Code in this region runs on the rendering thread.
# Check if our shader has changed and needs to be recompiled.
func _check_shader() -> bool:
	if not rd:
		return false

	var new_shader_code := ""

	# Check if our shader is dirty.
	mutex.lock()
	if shader_is_dirty:
		new_shader_code = shader_code
		shader_is_dirty = false
	mutex.unlock()

	# We don't have a (new) shader?
	if new_shader_code.is_empty():
		return pipeline.is_valid()

	# Apply template.
	new_shader_code = template_shader.replace("#COMPUTE_CODE", new_shader_code);

	# Out with the old.
	if shader.is_valid():
		rd.free_rid(shader)
		shader = RID()
		pipeline = RID()

	# In with the new.
	var shader_source := RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = new_shader_code
	var shader_spirv : RDShaderSPIRV = rd.shader_compile_spirv_from_source(shader_source)

	if shader_spirv.compile_error_compute != "":
		push_error(shader_spirv.compile_error_compute)
		push_error("In: " + new_shader_code)
		return false

	shader = rd.shader_create_from_spirv(shader_spirv)
	if not shader.is_valid():
		return false

	pipeline = rd.compute_pipeline_create(shader)

	return pipeline.is_valid()


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and _check_shader():
		# Get our render scene buffers object, this gives us access to our render buffers.
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		var scene_data := p_render_data.get_render_scene_data()
		if render_scene_buffers && scene_data:
			# Get our render size, this is the 3D render resolution!
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# We can use a compute shader here.
			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			# Create push constant.
			# Must be aligned to 16 bytes and be in the same order as defined in the shader.
			var push_constant := PackedFloat32Array([
				size.x,
				size.y,
				0.0,
				0.0,
			])

			# Make sure we have a sampler
			if not nearest_sampler.is_valid():
				var sampler_state : RDSamplerState = RDSamplerState.new()
				sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
				sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
				nearest_sampler = rd.sampler_create(sampler_state)

			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count: int = render_scene_buffers.get_view_count()
			for view in view_count:
				# Get the RID for our scene data buffer
				var scene_data_buffers: RID = scene_data.get_uniform_buffer()

				# Get the RID for our color image, we will be reading from and writing to it.
				var color_image: RID = render_scene_buffers.get_color_layer(view)

				# Get the RID for our depth image, we will be reading from it.
				var depth_image: RID = render_scene_buffers.get_depth_layer(view)

				# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed.
				var scene_data_uniform := RDUniform.new()
				scene_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
				scene_data_uniform.binding = 0
				scene_data_uniform.add_id(scene_data_buffers)
				var color_uniform := RDUniform.new()
				color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				color_uniform.binding = 1
				color_uniform.add_id(color_image)
				var depth_uniform := RDUniform.new()
				depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				depth_uniform.binding = 2
				depth_uniform.add_id(nearest_sampler)
				depth_uniform.add_id(depth_image)
				var uniform_set := UniformSetCacheRD.get_cache(shader, 0, [scene_data_uniform, color_uniform, depth_uniform])

				# Set our view
				push_constant[2] = view

				# Run our compute shader.
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
#endregion
