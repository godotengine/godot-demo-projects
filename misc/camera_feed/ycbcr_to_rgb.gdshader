shader_type canvas_item;

uniform sampler2D rgb_texture;
// Y component texture (Feed ID 1 -> FEED_Y_IMAGE)
uniform sampler2D y_texture;
// CbCr component texture (Feed ID 2 -> FEED_CBCR_IMAGE)
uniform sampler2D cbcr_texture;
// mode: 0 -> RGB, mode: 1 -> YCbCr
uniform int mode : hint_range(0, 1);

// YCbCr to RGB conversion (BT.601 standard)
void fragment() {
	vec3 color;
	color.r = texture(y_texture, UV).r;
	color.gb = texture(cbcr_texture, UV).rg - vec2(0.5, 0.5);

	// YCbCr -> SRGB conversion
	// Using BT.709 which is the standard for HDTV
	color.rgb = mat3(
					vec3(1.00000, 1.00000, 1.00000),
					vec3(0.00000, -0.18732, 1.85560),
					vec3(1.57481, -0.46813, 0.00000))
					* color.rgb;

	vec3 rgb = texture(rgb_texture, UV).rgb;
	COLOR = vec4(mix(rgb, color, float(mode)), 1.0);
}
