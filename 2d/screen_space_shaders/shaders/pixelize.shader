shader_type canvas_item;

uniform float size_x = 0.008;
uniform float size_y = 0.008;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv -= mod(uv, vec2(size_x, size_y));
	
	COLOR.rgb = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
}
