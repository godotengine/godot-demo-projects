shader_type canvas_item;

render_mode blend_mix;
uniform vec4 modulate : source_color;

// Allows CanvasItem `modulate` and `self_modulate` properties to work as intended.
varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	COLOR = vec4(modulate.rgb, texture(TEXTURE, UV).a * modulate.a) * vertex_color;
}
