extends Spatial

func _ready():
	pass


# Random spawn of Rigidbody cubes.
func _on_SpawnTimer_timeout():
	var rb = preload("res://cubeRB.tscn")
	var new_rb = rb.instance()
	new_rb.translation.y = 15
	new_rb.translation.x = rand_range(-5, 5)
	new_rb.translation.z = rand_range(-5, 5)
	add_child(new_rb)
