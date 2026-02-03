shader_type canvas_item;
render_mode unshaded;

uniform float log2_min = -18.0;
uniform float log2_max = 5.0;
uniform bool clip_to_max = false;
uniform float max_value = 10;

void fragment() {
	vec3 color;
	float top_bar = 0.05;
	float log2_value = UV.x * (log2_max - log2_min) + log2_min;
	float scale = pow(2.0, log2_value);

	if (UV.y >= top_bar) {
		float padding = 0.005;
		float y = (UV.y - top_bar - padding) / (1.0 - top_bar - padding * 2.0);
		y = clamp(y, 0.0, 1.0);
		float segments = 1.0 / 6.0;
		vec3 col = vec3(0);
		if (y < segments) {
			col.r = 1.0;
			col.g = y / segments;
			col.b = 0.0;
		} else if (y < segments * 2.0) {
			col.r = (y - segments * 2.0) / -segments;
			col.g = 1.0;
			col.b = 0.0;
		} else if (y < segments * 3.0) {
			col.r = 0.0;
			col.g = 1.0;
			col.b = (y - segments * 2.0) / segments;
		} else if (y < segments * 4.0) {
			col.r = 0.0;
			col.g = (y - segments * 4.0) / -segments;
			col.b = 1.0;
		} else if (y < segments * 5.0) {
			col.r = (y - segments * 4.0) / segments;
			col.g = 0.0;
			col.b = 1.0;
		} else {
			col.r = 1.0;
			col.g = 0.0;
			col.b = (y - segments * 6.0) / -segments;
		}

		color = col * scale;
	} else {
		color = vec3(1.0) * scale;

		if (UV.y < 0.01) {
			// Max  value mark:
			float max_log2 = log2(max_value);
			float scale_log2 = log2(scale);
			float mark_size = 0.03;
			if (scale_log2 > max_log2 - mark_size && scale_log2 < max_log2 + mark_size) {
				color = vec3(0);
			}
		} else if (UV.y > 0.03) {
			// Log scale marks:
			float tick_col = scale > 0.184 ? 0.0 : 1.0;
			while (scale >= 1.0) {
				scale /= 10.0;
			}
			while (scale < 0.1) {
				scale *= 10.0;
			}
			float tick_threshold = scale * 0.02;
			if ((scale > 1.0 - tick_threshold && scale < 1.0 + tick_threshold)
					|| (scale > 0.0 - tick_threshold && scale < 0.0 + tick_threshold)
					|| (scale > 0.1 - tick_threshold && scale < 0.1 + tick_threshold)) {
				color = vec3(tick_col);
			} else if (UV.y > 0.04
					&& ((scale > 0.9 - tick_threshold && scale < 0.9 + tick_threshold)
					|| (scale > 0.8 - tick_threshold && scale < 0.8 + tick_threshold)
					|| (scale > 0.7 - tick_threshold && scale < 0.7 + tick_threshold)
					|| (scale > 0.6 - tick_threshold && scale < 0.6 + tick_threshold)
					|| (scale > 0.5 - tick_threshold && scale < 0.5 + tick_threshold)
					|| (scale > 0.4 - tick_threshold && scale < 0.4 + tick_threshold)
					|| (scale > 0.3 - tick_threshold && scale < 0.3 + tick_threshold)
					|| (scale > 0.2 - tick_threshold && scale < 0.2 + tick_threshold))) {
				color = vec3(tick_col);
			}
		}
	}

	if (clip_to_max) {
		color = min(color, max_value);
	}

	COLOR = vec4(color.rgb, 1.0);
}
