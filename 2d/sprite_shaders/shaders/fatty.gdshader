shader_type canvas_item;

render_mode blend_mix;
uniform float fattyness = 2.0;

// Allows CanvasItem `modulate` and `self_modulate` properties to work as intended.
varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 ruv = UV - vec2(0.5, 0.5);
	vec2 dir = normalize(ruv);
	float len = length(ruv);

	len = pow(len * 2.0, fattyness) * 0.5;
	ruv = len * dir;

	vec4 col = texture(TEXTURE, ruv + vec2(0.5, 0.5));

	COLOR = col * vertex_color;
}
