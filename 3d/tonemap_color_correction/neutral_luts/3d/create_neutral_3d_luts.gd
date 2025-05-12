# This script can be run from the script editor (File > Run or press Ctrl + Shift + X).
@tool
extends EditorScript

## Creates a neutral 3D look-up texture (LUT), i.e. where the input color matches the output color exactly.
## Using a high-resolution neutral LUT texture in Environment's color correction property will not
## *visibly* appear rendering, even though the LUT is still sampled.
## Lower resolution neutral LUTs such as 17×17×17 and 33×33×33 will still somewhat impact rendering
## due to the limitations of bilinear filtering.
func create_neutral_lut(p_name: String, p_size: int, p_vertical: bool):
	var image = Image.create_empty(
			p_size if p_vertical else (p_size * p_size),
			(p_size * p_size) if p_vertical else p_size,
			false,
			Image.FORMAT_RGB8
	)

	for z in p_size:
		var x_offset := int(z * p_size) if not p_vertical else 0
		var y_offset := int(z * p_size) if p_vertical else 0
		for x in p_size:
			for y in p_size:
				# Bias rounding by +0.2 to be more neutral, especially at lower resolutions
				# (this bias is empirically determined).
				image.set_pixel(x_offset + x, y_offset + y, Color8(
						roundi(((x + 0.2) / float(p_size - 1)) * 255),
						roundi(((y + 0.2) / float(p_size - 1)) * 255),
						roundi(((z + 0.2) / float(p_size - 1)) * 255)
				))

	image.save_png("user://" + p_name + ".png")


func _run() -> void:
	create_neutral_lut("lut_neutral_17x17x17_horizontal", 17, false)
	create_neutral_lut("lut_neutral_33x33x33_horizontal", 33, false)
	create_neutral_lut("lut_neutral_51x51x51_horizontal", 51, false)
	create_neutral_lut("lut_neutral_65x65x65_horizontal", 65, false)
	create_neutral_lut("lut_neutral_17x17x17_vertical", 17, true)
	create_neutral_lut("lut_neutral_33x33x33_vertical", 33, true)
	create_neutral_lut("lut_neutral_51x51x51_vertical", 51, true)
	create_neutral_lut("lut_neutral_65x65x65_vertical", 65, true)

	# Open destination folder containing the generated LUT images.
	# After importing the textures in a project, remember to change their import mode to Texture3D
	# in the Import dock as well as the number of horizontal/vertical slices.
	OS.shell_open(ProjectSettings.globalize_path("user://"))
