extends Node3D

@export var base_colors: Array[Color]
@export var meshes: Array[MeshInstance3D]
@export var time_between_flashes: float = 0.2

var _time_passed: float = 0.0
var _mesh_index: int = 0


func _ready() -> void:
	seed(0)
	meshes.shuffle()

	var color_index = 0

	for mesh in meshes:
		color_index += 1
		if color_index >= base_colors.size():
			color_index = 0

		var material: StandardMaterial3D = mesh.get_active_material(0).duplicate() as StandardMaterial3D
		material.albedo_color = base_colors[color_index]
		mesh.material_override = material
		mesh.set_script(preload("res://output_max_linear_value/color_flash.gd"))


func _process(delta: float) -> void:
	_time_passed += delta
	if _time_passed > time_between_flashes:
		meshes[_mesh_index].flash()
		_mesh_index += 1
		if _mesh_index >= meshes.size():
			_mesh_index = 0
		_time_passed -= time_between_flashes
