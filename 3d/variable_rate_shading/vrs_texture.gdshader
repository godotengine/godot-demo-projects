shader_type canvas_item;

void fragment() {
	float vrs = texture(TEXTURE, UV).r * 255.0;

	// Map valid entries to human-visible colors.
	// This is only used if using the red channel colors between 0.0/255 and 10.0/255,
	// rather than relying on Godot to aliases the output colors below to variable shading rates.
	//
	// `vrs_texture.png` in this project already uses the aliased colors for convenience,
	// but `vrs_texture_original.png` does not.
	// The output shading rate from those two textures is identical.
	if (vrs == 0.0) { // 1x1
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else if (vrs == 1.0) { // 1x2
		COLOR = vec4(0.0, 0.5, 0.0, 1.0);
	} else if (vrs == 4.0) { // 2x1
		COLOR = vec4(0.5, 0.0, 0.0, 1.0);
	} else if (vrs == 5.0) { // 2x2
		COLOR = vec4(0.5, 0.5, 0.0, 1.0);
	} else if (vrs == 6.0) { // 2x4
		COLOR = vec4(0.5, 1.0, 0.0, 1.0);
	} else if (vrs == 9.0) { // 4x2
		COLOR = vec4(1.0, 0.5, 0.0, 1.0);
	} else if (vrs == 10.0) { // 4x4
		COLOR = vec4(1.0, 1.0, 0.0, 1.0);
	} else {
		COLOR = vec4(1.0, 0.5, 1.0, 1.0);
	}
}
