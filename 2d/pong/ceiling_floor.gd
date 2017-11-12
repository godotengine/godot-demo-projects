extends Area2D

export var y_direction = 1

func _on_area_entered( area ):
	if area.get_name() == "ball":
		area.direction.y = y_direction
