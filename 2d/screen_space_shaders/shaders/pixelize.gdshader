shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float size_x = 0.008;
uniform float size_y = 0.008;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv -= mod(uv, vec2(size_x, size_y));

	COLOR.rgb = textureLod(screen_texture, uv, 0.0).rgb;
}
