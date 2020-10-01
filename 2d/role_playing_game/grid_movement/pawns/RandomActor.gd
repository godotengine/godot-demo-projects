extends "Actor.gd"

const DIRECTIONS = [-1, 1]

func get_input_direction():
	if not active:
		return Vector2()
	var random_x = DIRECTIONS[randi() % DIRECTIONS.size()]
	var random_y = DIRECTIONS[randi() % DIRECTIONS.size()]

	var random_axis = randi() % 2
	if random_axis > 0:
		random_x = 0
	else:
		random_y = 0
	return Vector2(random_x, random_y)
