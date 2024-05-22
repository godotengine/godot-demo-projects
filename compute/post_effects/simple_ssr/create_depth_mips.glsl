#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our push PushConstant
layout(push_constant, std430) uniform Params {
	vec2 render_size;
	vec2 half_size;
} params;

// layout(set = 0, binding = 0) uniform sampler2D depth_image;
layout(r32f, set = 0, binding = 0) uniform restrict readonly image2D depth_image;

layout(r32f, set = 1, binding = 0) uniform restrict writeonly image2D depth_mip1;
layout(r32f, set = 1, binding = 1) uniform restrict writeonly image2D depth_mip2;
layout(r32f, set = 1, binding = 2) uniform restrict writeonly image2D depth_mip3;
layout(r32f, set = 1, binding = 3) uniform restrict writeonly image2D depth_mip4;

// Share our results
shared float min_buffer[8][8];

// The code we want to execute in each invocation
void main() {
	ivec2 dest_uv = ivec2(gl_GlobalInvocationID.xy);
	uvec2 grp_uv = gl_LocalInvocationID.xy;

	ivec2 render_size = ivec2(params.render_size.xy);
	// ivec2 half_size = ivec2(params.half_size.xy);

	ivec2 source_uv = dest_uv * 2;

	{
		float d1 = 1.0;
		float d2 = 1.0;
		float d3 = 1.0;
		float d4 = 1.0;

		if (source_uv.x < render_size.x && source_uv.y < render_size.y) {
			d1 = imageLoad(depth_image, source_uv).r;
		}
		if (source_uv.x + 1 < render_size.x && source_uv.y < render_size.y) {
			d2 = imageLoad(depth_image, source_uv + ivec2(1, 0)).r;
		}
		if (source_uv.x < render_size.x && source_uv.y + 1 < render_size.y) {
			d3 = imageLoad(depth_image, source_uv + ivec2(0, 1)).r;
		}
		if (source_uv.x < render_size.x + 1 && source_uv.y + 1 < render_size.y) {
			d4 = imageLoad(depth_image, source_uv + ivec2(1, 1)).r;
		}

		float d = min(min(d1, d2), min(d3, d4));
		min_buffer[grp_uv.x][grp_uv.y] = d;

		imageStore(depth_mip1, dest_uv, vec4(d, d, d, d));
	}

	// Prepare next..
	bool continue_mips = grp_uv.x % 2 == 0 && grp_uv.y % 2 == 0;
	dest_uv /= 2;

	// Wait for our group
	groupMemoryBarrier();
	barrier();

	if (continue_mips) {
		float d1 = min_buffer[grp_uv.x + 0][grp_uv.y + 0];
		float d2 = min_buffer[grp_uv.x + 1][grp_uv.y + 0];
		float d3 = min_buffer[grp_uv.x + 0][grp_uv.y + 1];
		float d4 = min_buffer[grp_uv.x + 1][grp_uv.y + 1];

		float d = min(min(d1, d2), min(d3, d4));
		min_buffer[grp_uv.x][grp_uv.y] = d;

		imageStore(depth_mip2, dest_uv, vec4(d, d, d, d));
	}

	// Prepare next..
	continue_mips = grp_uv.x % 4 == 0 && grp_uv.y % 4 == 0;
	dest_uv /= 2;

	// Wait for our group
	groupMemoryBarrier();
	barrier();

	if (continue_mips) {
		float d1 = min_buffer[grp_uv.x + 0][grp_uv.y + 0];
		float d2 = min_buffer[grp_uv.x + 2][grp_uv.y + 0];
		float d3 = min_buffer[grp_uv.x + 0][grp_uv.y + 2];
		float d4 = min_buffer[grp_uv.x + 2][grp_uv.y + 2];

		float d = min(min(d1, d2), min(d3, d4));
		min_buffer[grp_uv.x][grp_uv.y] = d;

		imageStore(depth_mip3, dest_uv, vec4(d, d, d, d));
	}

	// Prepare next..
	continue_mips = grp_uv.x % 8 == 0 && grp_uv.y % 8 == 0;
	dest_uv /= 2;

	// Wait for our group
	groupMemoryBarrier();
	barrier();

	if (continue_mips) {
		float d1 = min_buffer[grp_uv.x + 0][grp_uv.y + 0];
		float d2 = min_buffer[grp_uv.x + 4][grp_uv.y + 0];
		float d3 = min_buffer[grp_uv.x + 0][grp_uv.y + 4];
		float d4 = min_buffer[grp_uv.x + 4][grp_uv.y + 4];

		float d = min(min(d1, d2), min(d3, d4));
		min_buffer[grp_uv.x][grp_uv.y] = d;

		imageStore(depth_mip4, dest_uv, vec4(d, d, d, d));
	}
}
