extends Node

enum PhysicsEngine {
	GODOT_PHYSICS,
	OTHER,
}

var _engine: PhysicsEngine = PhysicsEngine.OTHER

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Always enable visible collision shapes on startup
	# (same as the Debug > Visible Collision Shapes option).
	get_tree().debug_collisions_hint = true

	var engine_string:= String(ProjectSettings.get_setting("physics/2d/physics_engine"))
	match engine_string:
		"DEFAULT":
			_engine = PhysicsEngine.GODOT_PHYSICS
		"GodotPhysics2D":
			_engine = PhysicsEngine.GODOT_PHYSICS
		_:
			_engine = PhysicsEngine.OTHER


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"toggle_full_screen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	if Input.is_action_just_pressed(&"toggle_debug_collision"):
		var debug_collision_enabled := not _is_debug_collision_enabled()
		_set_debug_collision_enabled(debug_collision_enabled)
		if debug_collision_enabled:
			Log.print_log("Debug Collision ON")
		else:
			Log.print_log("Debug Collision OFF")

	if Input.is_action_just_pressed(&"toggle_pause"):
		get_tree().paused = not get_tree().paused

	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()


func get_physics_engine() -> PhysicsEngine:
	return _engine


func _set_debug_collision_enabled(enabled: bool) -> void:
	get_tree().debug_collisions_hint = enabled


func _is_debug_collision_enabled() -> bool:
	return get_tree().debug_collisions_hint
