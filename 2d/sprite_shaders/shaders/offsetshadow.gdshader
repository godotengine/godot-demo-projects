shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(8.0, 8.0);
uniform vec4 modulate : hint_color;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;

	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, UV - offset * ps).a * modulate.a);
	vec4 col = texture(TEXTURE, UV);

	COLOR = mix(shadow, col, col.a);
}
