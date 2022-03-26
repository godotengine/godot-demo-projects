shader_type canvas_item;
render_mode blend_mix;

uniform float radius = 4.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;

	col += texture(TEXTURE, UV + vec2(0.0, -radius) * ps);
	col += texture(TEXTURE, UV + vec2(0.0, radius) * ps);
	col += texture(TEXTURE, UV + vec2(-radius, 0.0) * ps);
	col += texture(TEXTURE, UV + vec2(radius, 0.0) * ps);
	col /= 5.0;

	COLOR = col;
}
