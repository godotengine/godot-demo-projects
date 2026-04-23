extends Node3D

@export var color_speed: float = 0.1

@onready var light: Light3D = $"OmniLight3D"
@onready var material: StandardMaterial3D = $"geodesic-sphere/GD_mesh_002".material_override as StandardMaterial3D

var current_hue: float = 0.0


func _process(delta: float) -> void:
	current_hue += color_speed * delta
	if current_hue > 1.0:
		current_hue -= 1.0
	var new_color = Color.from_hsv(current_hue, 1.0, 1.0)
	light.light_color = new_color
	material.emission = new_color
