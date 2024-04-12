#[compute]
#version 450

// Invocations in the (x, y, z) dimension.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our textures.
layout(r32f, set = 0, binding = 0) uniform restrict readonly image2D current_image;
layout(r32f, set = 1, binding = 0) uniform restrict readonly image2D previous_image;
layout(r32f, set = 2, binding = 0) uniform restrict writeonly image2D output_image;

// Our push PushConstant.
layout(push_constant, std430) uniform Params {
	vec4 add_wave_point;
	vec2 texture_size;
	float damp;
	float res2;
} params;

// The code we want to execute in each invocation.
void main() {
	ivec2 tl = ivec2(0, 0);
	ivec2 size = ivec2(params.texture_size.x - 1, params.texture_size.y - 1);

	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

	// Just in case the texture size is not divisable by 8.
	if ((uv.x > size.x) || (uv.y > size.y)) {
		return;
	}

	float current_v = imageLoad(current_image, uv).r;
	float up_v = imageLoad(current_image, clamp(uv - ivec2(0, 1), tl, size)).r;
	float down_v = imageLoad(current_image, clamp(uv + ivec2(0, 1), tl, size)).r;
	float left_v = imageLoad(current_image, clamp(uv - ivec2(1, 0), tl, size)).r;
	float right_v = imageLoad(current_image, clamp(uv + ivec2(1, 0), tl, size)).r;
	float previous_v = imageLoad(previous_image, uv).r;

	float new_v = 2.0 * current_v - previous_v + 0.25 * (up_v + down_v + left_v + right_v - 4.0 * current_v);
	new_v = new_v - (params.damp * new_v * 0.001);

	if (params.add_wave_point.z > 0.0 && uv.x == floor(params.add_wave_point.x) && uv.y == floor(params.add_wave_point.y)) {
		new_v = params.add_wave_point.z;
	}

	if (new_v < 0.0) {
		new_v = 0.0;
	}
	vec4 result = vec4(new_v, new_v, new_v, 1.0);

	imageStore(output_image, uv, result);
}
