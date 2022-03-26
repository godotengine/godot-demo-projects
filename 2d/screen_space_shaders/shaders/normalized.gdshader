shader_type canvas_item;

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	COLOR.rgb = normalize(c);
}
