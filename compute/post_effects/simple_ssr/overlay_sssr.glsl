#[vertex]

#version 450

layout(location = 0) out vec2 uv_interp;

void main() {
	vec2 base_arr[3] = vec2[](vec2(-1.0, -1.0), vec2(-1.0, 3.0), vec2(3.0, -1.0));
	gl_Position = vec4(base_arr[gl_VertexIndex], 0.0, 1.0);
	uv_interp = clamp(gl_Position.xy, vec2(0.0, 0.0), vec2(1.0, 1.0)) * 2.0; // saturate(x) * 2.0
}

#[fragment]

#version 450

layout(location = 0) in vec2 uv_interp;

layout(set = 0, binding = 0) uniform sampler2D reflection_color;

layout(location = 0) out vec4 frag_color;

void main() {
    vec4 color = textureLod(reflection_color, uv_interp, 0);
    color.a = 1.0;

	frag_color = color;
}
