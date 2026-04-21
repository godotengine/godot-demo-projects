extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_spawn_function(spawn_player)
	pass # Replace with function body.



func spawn_player(data: Array) -> CharacterBody2D:
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT:
		return null
	
	var player: CharacterBody2D = preload("res://player.tscn").instantiate()
	player.synced_position = data[0]
	player.name = str(data[1])
	return player
