shader_type spatial;
render_mode unshaded;

uniform vec4 albedo : source_color = vec4(1.0);

varying float factor;

void vertex() {
	factor = smoothstep(0.08, 0.15, length(VERTEX));
}

void fragment() {
	ALBEDO = albedo.rgb;

	float d = dot(NORMAL, vec3(0.0, 0.0, 1.0));
	ALPHA = (0.05 + 0.95 * smoothstep(0.5, 1.0, 1.0 - abs(d))) * factor;
}
