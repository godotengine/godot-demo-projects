extends MultiplayerSpawner

func _init():
	spawn_function = _spawn_bomb


func _spawn_bomb(data):
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT:
		return null
	var bomb = preload("res://bomb.tscn").instantiate()
	bomb.position = data[0]
	bomb.from_player = data[1]
	return bomb
