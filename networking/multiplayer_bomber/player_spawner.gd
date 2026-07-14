extends MultiplayerSpawner

func _ready() -> void:
	set_spawn_function(spawn_player)


func spawn_player(data: Array) -> CharacterBody2D:
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT:
		push_error("Invalid MultiplayerSpawner spawn parameter. The parameter must be an array with 2 elements, where index 0 is the Vector2 spawn position and index 1 is the spawn point index.")
		return null
	var player: CharacterBody2D = preload("res://player.tscn").instantiate()
	player.synced_position = data[0]
	player.name = str(data[1])
	return player
