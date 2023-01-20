extends Area3D


func _on_body_entered(body):
	if body is Player:
		body.in_water = true
		body.water_plane_y = global_position.y

func _on_body_exited(body):
	if body is Player:
		body.in_water = false
		body.water_plane_y = -INF
