extends DirectionalLight3D


func _process(delta):
	rotate_object_local(Vector3.RIGHT, 0.025 * delta)
	#rotate_object_local(Vector3.FORWARD, randf())
