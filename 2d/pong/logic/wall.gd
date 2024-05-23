extends Area2D

func _on_wall_area_entered(area: Area2D) -> void:
	if area.name == "Ball":
		# Ball went out of bounds, reset.
		area.reset()
