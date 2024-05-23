extends Node3D

# Random spawn of Rigidbody cubes.
func _on_SpawnTimer_timeout() -> void:
	var new_rb: RigidBody3D = preload("res://cube_rigidbody.tscn").instantiate()
	new_rb.position.y = 15
	new_rb.position.x = randf_range(-5, 5)
	new_rb.position.z = randf_range(-5, 5)
	add_child(new_rb)
