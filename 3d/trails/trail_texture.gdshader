shader_type spatial;
render_mode blend_add, depth_draw_never, unshaded, cull_front;

uniform sampler2D texture_albedo : filter_linear_mipmap_anisotropic;

void vertex() {
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
	}
}

void fragment() {
	vec4 texture_albedo_sampled = texture(texture_albedo, UV);
	ALBEDO = COLOR.rgb * texture_albedo_sampled.rgb;
	ALPHA = COLOR.a * texture_albedo_sampled.a;
}
