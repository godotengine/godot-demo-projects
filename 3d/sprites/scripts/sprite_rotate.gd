extends Sprite3D

@export var speed_deg: float = 90.0


func _process(delta: float) -> void:
	rotate_y(deg_to_rad(speed_deg * delta))
