shader_type canvas_item;
render_mode blend_mix;

uniform float amount = 20.0;

void fragment() {
	vec2 uv = UV * 0.05;
	float a = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 438.5453);
	vec4 col = texture(TEXTURE, UV);

	col.a *= pow(a, amount);

	COLOR = col;
}
