@tool
extends Node3D

@export_range(0, 1, 0.1) var fade = 0.0:
	set(value):
		fade = value
		if is_inside_tree():
			_update_fade()

var material : ShaderMaterial

func _update_fade():
	if fade == 0.0:
		$MeshInstance3D.visible = false
	else:
		if material:
			material.set_shader_parameter("albedo", Color(0.0, 0.0, 0.0, fade))
		$MeshInstance3D.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	material = $MeshInstance3D.material_override
	_update_fade()
