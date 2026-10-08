shader_type spatial;
// Shader to animate a fish model.
// This shader is applied to each mesh surface material and receives the original albedo color.
// Instance uniforms allow the following values to be edited on all surfaces at the same time.
// Instance uniforms appear in the Inspector's GemoetryInstance3D section for nodes using the shader.
// Instance uniforms are not shared between nodes.
uniform vec4 albedo : source_color;
instance uniform float time_scale = 3.0;
instance uniform float side_to_side = 0.2;
instance uniform float pivot = 0.4;
instance uniform float wave = 1.5;
instance uniform float twist = 1.5;
/**
 * Calculated in code and updated automatically. Should not be edited unless
 * the calculation has issues.
 */
uniform float mesh_length = 8.015;
/**
 * Calculated in code and updated automatically. Should not be edited unless
 * the calculation has issues.
 */
uniform vec3 mesh_center = vec3(0.0, 0.206102, -1.00322);

void vertex() {
	// Check if custom data has been uploaded.
	bool custom = INSTANCE_CUSTOM.x != 0.0 || INSTANCE_CUSTOM.w != 0.0;

	// Make center vertex of model (0, 0, 0).
	VERTEX -= mesh_center;

	// Speed of animation.
	float time = 0.0;

	if (custom) {
		// Multimesh sets speeds randomly, while GPU particles link it with velocity.
		// Both use INSTANCE_CUSTOM.
		time = (TIME * (0.5 + INSTANCE_CUSTOM.w) * time_scale) + time_scale * (2.0 * PI * INSTANCE_CUSTOM.x);
	} else {
		time = TIME * time_scale;
	}

	// Side to side motion
	VERTEX.x += cos(time) * side_to_side;

	// Pivot motion
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(
			vec2(cos(pivot_angle), -sin(pivot_angle)),
			vec2(sin(pivot_angle), cos(pivot_angle)));
	VERTEX.xz = rotation_matrix * VERTEX.xz;

	// Wave along length of body.
	float body = (VERTEX.z + mesh_length / 2.0) / mesh_length;
	float mask = smoothstep(0.0, 1.0, 1.0 - body);
	VERTEX.x += cos(time + PI * body) * mask * wave;

	// Instance custom can be used to alter the fish's color per instance in fragment().
	// Otherwise, can be used to view the above mask, as in the tutorial.
	COLOR = vec4(INSTANCE_CUSTOM.rgb, mask);

	// Twist along length of body.
	float twist_angle = cos(time + body) * 0.3 * twist;
	mat2 twist_matrix = mat2(
			vec2(cos(twist_angle), -sin(twist_angle)),
			vec2(sin(twist_angle), cos(twist_angle)));
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, mask);
}

void fragment() {
	// Color using supplied albedo.
	ALBEDO = albedo.rgb;

	// Vary albedo color if custom data was written to COLOR.
	if (length(COLOR.rgb) > 0.01) {
		ALBEDO *= COLOR.rgb;
	}

	// To view the mask set in vertex():
	//ALBEDO = COLOR.aaa;
}
