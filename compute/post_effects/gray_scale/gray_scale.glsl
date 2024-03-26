#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

	vec4 color = imageLoad(color_image, uv);
	float gray = color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;
	color.rgb = vec3(gray);

	imageStore(color_image, uv, color);
}
