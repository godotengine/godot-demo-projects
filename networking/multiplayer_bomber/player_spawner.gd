extends MultiplayerSpawner

func _init() -> void:
	spawn_function = _spawn_player


func _spawn_player(data: Array) -> Area2D:
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT:
		return null

	var player: Area2D = preload("res://player.tscn").instantiate()
	player.position = data[0]
	player.name = data[1]
	return player
