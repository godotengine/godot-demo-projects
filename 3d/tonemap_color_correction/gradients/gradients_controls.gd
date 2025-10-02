extends Node

@export var bars: Array[NodePath]
@export var max_value_label: Label3D
@export var colors: Array[Color]
@export var custom_bar: GradientBars
@export var hues: MeshInstance3D

func _ready():
	for i in range(colors.size()):
		var bar_path: NodePath = bars[i]
		var bar: GradientBars = get_node(bar_path) as GradientBars
		var col: Color = colors[i]
		bar.set_color(col)

	_on_steps_value_changed(6)
	_on_color_picker_button_color_changed(Color(0.5, 0.5, 0.5, 1))
	_on_exponential_toggled(false)

func _on_steps_value_changed(value):
	max_value_label.text = "%.1f" % value
	for bar_path in bars:
		var bar = get_node(bar_path)
		var shader_mat = bar.hdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter("steps", value)
	if hues:
		var shader_mat = hues.material_override as ShaderMaterial
		shader_mat.set_shader_parameter("steps", value)


func _on_color_picker_button_color_changed(color):
	if custom_bar:
		custom_bar.set_color(color)


func _on_exponential_toggled(button_pressed):
	for bar_path in bars:
		var bar = get_node(bar_path)
		var shader_mat = bar.hdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter("exponential_view", button_pressed)

		shader_mat = bar.sdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter("exponential_view", button_pressed)
	if hues:
		var shader_mat = hues.material_override as ShaderMaterial
		shader_mat.set_shader_parameter("exponential_view", button_pressed)
