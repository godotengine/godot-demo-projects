shader_type canvas_item;

uniform sampler2D rgb_texture;
// Y component texture (Feed ID 1 -> FEED_Y_IMAGE)
uniform sampler2D y_texture;
// CbCr component texture (Feed ID 2 -> FEED_CBCR_IMAGE)
uniform sampler2D cbcr_texture;
// YCbCr component texture (Feed ID 1 -> FEED_YCBCR_IMAGE)
uniform sampler2D ycbcr_texture;
// mode: 0 -> RGB, mode: 1 -> YCbCr_sep, mode: 2 -> YCbCr
uniform int mode : hint_range(0, 2);

// YCbCr to RGB conversion (BT.601 standard)
void fragment() {
	vec3 color;

	if (mode == 1) {
		color.r = texture(y_texture, UV).r;
		color.gb = texture(cbcr_texture, UV).rg - vec2(0.5, 0.5);
	} else if (mode == 2) {
		vec2 UV_u = UV - floor(mod(UV / TEXTURE_PIXEL_SIZE, 2)) * vec2(1, 0) * TEXTURE_PIXEL_SIZE;
		vec2 UV_v = UV + (vec2(1, 0) - floor(mod(UV / TEXTURE_PIXEL_SIZE, 2))) * vec2(1, 0) * TEXTURE_PIXEL_SIZE;
		color.r = texture(ycbcr_texture, UV).r;
		color.g = texture(ycbcr_texture, UV_u).g - 0.5;
		color.b = texture(ycbcr_texture, UV_v).g - 0.5;
	}

	// YCbCr -> SRGB conversion
	// Using BT.709 which is the standard for HDTV
	color.rgb = mat3(
					vec3(1.00000, 1.00000, 1.00000),
					vec3(0.00000, -0.18732, 1.85560),
					vec3(1.57481, -0.46813, 0.00000))
					* color.rgb;

	vec3 rgb = texture(rgb_texture, UV).rgb;
	COLOR = vec4(mix(rgb, color, clamp(float(mode), 0.0, 1.0)), 1.0);
}
