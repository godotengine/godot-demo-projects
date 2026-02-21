extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var player := body as Player
		player.in_water = true
		player.water_plane_y = global_position.y

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		var player := body as Player
		player.in_water = false
		player.water_plane_y = -INF
