shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, depth_prepass_alpha;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform float outline_thickness : hint_range(0.001, 0.05) = 0.1;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;
	vec4 center = texture(texture_albedo, uv);

	float threshold = 0.1;
	float outline = 0.0;

	vec2 offset = vec2(outline_thickness, 0.0);

	outline += step(threshold, texture(texture_albedo, uv + offset).a);
	outline += step(threshold, texture(texture_albedo, uv - offset).a);
	outline += step(threshold, texture(texture_albedo, uv + vec2(0.0, outline_thickness)).a);
	outline += step(threshold, texture(texture_albedo, uv - vec2(0.0, outline_thickness)).a);

	if (center.a < threshold && outline > 0.0) {
		ALBEDO = outline_color.rgb;
		ALPHA = 1.0;
	} else {
		ALBEDO = center.rgb;
		ALPHA = center.a;
	}
}
