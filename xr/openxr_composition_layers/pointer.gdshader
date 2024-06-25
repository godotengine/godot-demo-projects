shader_type spatial;

uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 0.5);
uniform float energy = 1.0;

varying float f;

void vertex() {
	f = VERTEX.z + 0.5;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color.rgb;
	ALPHA = color.a * f * energy;
}
