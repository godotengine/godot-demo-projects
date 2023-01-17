shader_type spatial;
render_mode specular_disabled, cull_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;

void vertex() {
	// Y-billboard.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	// Ensure enemies in the darkness are always visible to an extent,
	// but allow them to be lit by light sources.
	EMISSION.rgb = tex.rgb * 0.25;
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
