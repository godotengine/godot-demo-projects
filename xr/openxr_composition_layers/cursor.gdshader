shader_type canvas_item;

uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	// Called for every pixel the material is visible on.
	float dist = length(UV - vec2(0.5, 0.5));
	COLOR.a = 1.0 - clamp(abs(0.4 - dist)/0.1, 0.0, 1.0);
}
