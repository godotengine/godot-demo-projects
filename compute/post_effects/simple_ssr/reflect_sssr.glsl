#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our push PushConstant
layout(push_constant, std430) uniform Params {
	mat4 projection;
	vec4 eye_offset;
	vec2 half_size;
	float max_distance;
	float max_steps;
} params;

layout(set = 0, binding = 0) uniform sampler2D depth_image;

layout(set = 1, binding = 0) uniform sampler2D normal_image;

layout(set = 2, binding = 0) uniform sampler2D color_image;

layout(rgba8, set = 3, binding = 0) uniform restrict writeonly image2D reflect_image;

// The code we want to execute in each invocation
void main() {
	float epsilon = 1e-6f;

	ivec2 depth_uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 dest_uv = depth_uv;
	vec2 uv = vec2(depth_uv) / params.half_size;

	vec4 reflection = vec4(0.0, 0.0, 0.0, 0.0);

	// ivec2 render_size = ivec2(params.render_size.xy);
	ivec2 half_size = ivec2(params.half_size.xy);

	if (depth_uv.x >= half_size.x || depth_uv.y >= half_size.y) {
		return;
	}

	// Calculate normal and roughness
	vec4 normal_roughness = textureLod(normal_image, uv, 0);
	vec3 normal = normalize(normal_roughness.rgb * 2.0 - 1.0);
	float roughness = normal_roughness.a;

	if (roughness >= 0.6) {
		imageStore(reflect_image, dest_uv, vec4(0.0));
		return;
	}

	// Calculate position
	float d = textureLod(depth_image, uv, 0).r;
	if (d + epsilon >= 1.0) {
		imageStore(reflect_image, dest_uv, vec4(0.0));
		return;
	}

	vec4 unproject = vec4(uv.x * 2.0 - 1.0, (1.0 - uv.y) * 2.0 - 1.0, d, 1.0);
	vec4 unprojected = inverse(params.projection) * unproject;
	vec3 vertex = unprojected.xyz / unprojected.w;

	vec3 view_dir = normalize(vertex + params.eye_offset.xyz);

	// Calculate reflection
	vec3 ray_dir = normalize(reflect(view_dir, normal));
	if (dot(ray_dir, normal) <= epsilon) {
		imageStore(reflect_image, dest_uv, vec4(0.0));
		return;
	}
	vec3 ray_end = vertex + (ray_dir * params.max_distance);

	vec4 pos = params.projection * vec4(vertex, 1.0);
	vec4 end_pos = params.projection * vec4(ray_end, 1.0); // TODO limit end to between near and far
	vec4 step = (end_pos - pos) / params.max_steps; // TODO change step size to actually follow pixels in depth map
	float delta = params.max_distance / params.max_steps;

	int level = 0;
	int was_level = 0;
	int max_steps = int(params.max_steps);
	vec2 curr_cell = depth_uv;
	float divider = 1;
	float dist = 0.0;

	while (level > -1) {
		pos += step;
		dist += delta;
		vec3 projected = pos.xyz / pos.w;

		uv = vec2(projected.x, -projected.y) * 0.5 + 0.5;

		vec2 new_cell = vec2(floor(uv.x * params.half_size.x / divider), floor(uv.y * params.half_size.y / divider));
		if (new_cell != curr_cell) {
			d = textureLod(depth_image, uv, level).r;
			/*
			if (level < 3 && projected.z <= d) {
				level += 1;
				divider *= 2.0;
				d = textureLod(depth_image, uv, level).r;
			}
			*/
			if (projected.z > d) {
				level -= 1;
				divider /= 2.0;
			}

			if (level > -1) {
				curr_cell = vec2(floor(uv.x * params.half_size.x / divider), floor(uv.y * params.half_size.y / divider));
			}
		}

		max_steps -= 1;
		if (max_steps == 0) {
			imageStore(reflect_image, dest_uv, vec4(0.0));
			return;
		} 
	}

	// Determine reflection
	normal_roughness = textureLod(normal_image, uv, 0);
	normal = normalize(normal_roughness.rgb * 2.0 - 1.0);

	if (dot(-ray_dir, normal) <= epsilon) {
		imageStore(reflect_image, dest_uv, vec4(0.0));
		return;
	}

	// Distance fadeout
	float fade = (params.max_distance - dist) / params.max_distance;

	vec4 color = textureLod(color_image, uv, 0);
	imageStore(reflect_image, dest_uv, vec4(color.rgb * fade, roughness));
}
