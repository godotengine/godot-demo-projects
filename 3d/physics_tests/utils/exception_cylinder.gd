extends Node


func _enter_tree():
	if System.get_physics_engine() == System.PhysicsEngine.GODOT_PHYSICS:
		Log.print_error("Cylinder shapes not supported, removing '%s'." % name)
		get_parent().remove_child(self)
		queue_free()
