shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	COLOR.rgb = normalize(c);
}
