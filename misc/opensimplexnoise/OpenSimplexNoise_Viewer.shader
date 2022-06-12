shader_type canvas_item;

uniform float min_value = -1;
uniform float max_value = 1;

void fragment() {
	// Get the color.
	vec4 color = texture(TEXTURE, UV);

	// Compare the value.
	float gray = color.x;
	if (gray < min_value) {
		color = vec4(0, 0, 0, 1);
	} else if (gray > max_value) {
		color = vec4(1, 1, 1, 1);
	}

	// Write back the color.
	COLOR = color;
}
