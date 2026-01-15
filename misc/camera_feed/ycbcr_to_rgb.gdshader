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
// color_range: 0 -> Full Range (0-255), 1 -> Video Range (16-235/240)
uniform int color_range : hint_range(0, 1) = 0;

// Convert YCbCr values based on color range
// Full Range: Y=0-255, CbCr=0-255 (normalized 0.0-1.0)
// Video Range: Y=16-235, CbCr=16-240 (needs scaling)
vec3 normalize_ycbcr(float y, vec2 cbcr) {
	vec3 result;
	if (color_range == 1) {
		// Video Range (Limited Range) - ITU-R BT.601/BT.709
		// Y: (Y - 16) / 219, CbCr: (CbCr - 16) / 224 - 0.5
		result.r = (y - 16.0 / 255.0) * (255.0 / 219.0);
		result.gb = (cbcr - 16.0 / 255.0) * (255.0 / 224.0) - vec2(0.5);
	} else {
		// Full Range - direct mapping
		result.r = y;
		result.gb = cbcr - vec2(0.5);
	}
	return result;
}

// YCbCr to RGB conversion
void fragment() {
	vec3 color;

	if (mode == 1) {
		// YCbCr separate planes (Y + CbCr)
		float y = texture(y_texture, UV).r;
		vec2 cbcr = texture(cbcr_texture, UV).rg;
		color = normalize_ycbcr(y, cbcr);
	} else if (mode == 2) {
		// YCbCr interleaved (YUYV/NV12 style)
		vec2 UV_u = UV - floor(mod(UV / TEXTURE_PIXEL_SIZE, 2)) * vec2(1, 0) * TEXTURE_PIXEL_SIZE;
		vec2 UV_v = UV + (vec2(1, 0) - floor(mod(UV / TEXTURE_PIXEL_SIZE, 2))) * vec2(1, 0) * TEXTURE_PIXEL_SIZE;
		float y = texture(ycbcr_texture, UV).r;
		vec2 cbcr = vec2(
			texture(ycbcr_texture, UV_u).g,
			texture(ycbcr_texture, UV_v).g
		);
		color = normalize_ycbcr(y, cbcr);
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
