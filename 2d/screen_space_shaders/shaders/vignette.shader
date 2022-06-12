shader_type canvas_item;

uniform sampler2D vignette;

void fragment() {
	vec3 vignette_color = texture(vignette, UV).rgb;
	// Screen texture stores gaussian blurred copies on mipmaps.
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, (1.0 - vignette_color.r) * 4.0).rgb;
	COLOR.rgb *= texture(vignette, UV).rgb;
}
