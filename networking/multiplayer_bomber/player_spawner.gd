extends MultiplayerSpawner

func _init() -> void:
	spawn_function = _spawn_player


func _spawn_player(data: Array) -> CharacterBody2D:
	if data.size() != 3 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT or typeof(data[2]) != TYPE_STRING:
		return null

	var player: CharacterBody2D = preload("res://player.tscn").instantiate()
	player.synced_position = data[0]
	player.name = str(data[1])
	player.set_player_name(data[2])
	return player
