shader_type spatial;
render_mode blend_add, depth_draw_never, unshaded, cull_disabled;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D texture_vertex_distortion : filter_linear, hint_default_black;
uniform float vertex_distortion_strength : hint_range(-10.0, 10.0, 0.001) = 1.0;
uniform float brightness : hint_range(0.0, 10.0, 0.001) = 1.0;
uniform float scroll_speed : hint_range(-100.0, 100.0, 0.001) = 5.0;

void vertex() {
	uint seed = uint(TIME * 10.0);
	// Billboarding code for trails.
	// `CUSTOM0` contains the tangent and width of the trail.
	if (dot(CUSTOM0.xyz, CUSTOM0.xyz) > 0.0) {
		vec3 p = (inverse(MODELVIEW_MATRIX) * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
		p = VERTEX - p;
		vec3 t = CUSTOM0.xyz;
		vec3 binormal = normalize(cross(p, t));
		vec3 normal = normalize(cross(t, binormal));
		vec3 tangent = normalize(cross(binormal, normal));
		VERTEX += CUSTOM0.w * binormal;
		NORMAL = normal;
		TANGENT = tangent;
		BINORMAL = binormal;

		VERTEX += (texture(texture_vertex_distortion, UV).rgb - vec3(0.5)) * vertex_distortion_strength;
	}
}

void fragment() {
	vec4 texture_albedo_sampled = texture(texture_albedo, UV + vec2(TIME * -scroll_speed, 0.0));
	ALBEDO = COLOR.rgb * texture_albedo_sampled.rgb * brightness;
	ALPHA = COLOR.a * texture_albedo_sampled.a;
}
