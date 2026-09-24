shader_type canvas_item;
render_mode blend_mix;

uniform float amount = 20.0;

// Allows CanvasItem `modulate` and `self_modulate` properties to work as intended.
varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = UV * 0.05;
	float a = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 438.5453);
	vec4 col = texture(TEXTURE, UV);

	col.a *= pow(a, amount);

	COLOR = col * vertex_color;
}
