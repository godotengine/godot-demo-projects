shader_type spatial;

void vertex() {
	VERTEX.z -= 0.6 - cos(VERTEX.x) * 0.6;
	VERTEX.x *= 0.8 + cos(VERTEX.x) * 0.2;
}

void fragment() {
	ALBEDO = vec3(1.0, 0.6, 0.1);
}
