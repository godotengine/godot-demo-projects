extends Node

var _tests : Array[Dictionary] = [
	{
		"id": "Functional Tests/Shapes",
		"path": "res://tests/functional/test_shapes.tscn",
	},
	{
		"id": "Functional Tests/Box Stack",
		"path": "res://tests/functional/test_stack.tscn",
	},
	{
		"id": "Functional Tests/Box Pyramid",
		"path": "res://tests/functional/test_pyramid.tscn",
	},
	{
		"id": "Functional Tests/Collision Pairs",
		"path": "res://tests/functional/test_collision_pairs.tscn",
	},
	{
		"id": "Functional Tests/Character - Slopes",
		"path": "res://tests/functional/test_character_slopes.tscn",
	},
	{
		"id": "Functional Tests/Character - Tilemap",
		"path": "res://tests/functional/test_character_tilemap.tscn",
	},
	{
		"id": "Functional Tests/Character - Pixels",
		"path": "res://tests/functional/test_character_pixels.tscn",
	},
	{
		"id": "Functional Tests/One Way Collision",
		"path": "res://tests/functional/test_one_way_collision.tscn",
	},
	{
		"id": "Functional Tests/Joints",
		"path": "res://tests/functional/test_joints.tscn",
	},
	{
		"id": "Functional Tests/Raycasting",
		"path": "res://tests/functional/test_raycasting.tscn",
	},
	{
		"id": "Performance Tests/Broadphase",
		"path": "res://tests/performance/test_perf_broadphase.tscn",
	},
	{
		"id": "Performance Tests/Contacts",
		"path": "res://tests/performance/test_perf_contacts.tscn",
	},
	{
		"id": "Performance Tests/Contact Islands",
		"path": "res://tests/performance/test_perf_contact_islands.tscn",
	},
	{
		"id": "Functional Tests/Solver/Rain on Pin Joint",
		"path": "res://tests/functional/solver/rain_on_pin_joint.tscn",
	},
	{
		"id": "Functional Tests/Solver/Bodies in Bucket",
		"path": "res://tests/functional/solver/bodies_in_bucket.tscn",
	},
]


func _ready() -> void:
	# UI should stay active during pause.
	# The rest of the UI will inherit this, except
	# for frame counter which only counts unpaused frames.
	process_mode = PROCESS_MODE_ALWAYS
	_get_default_options()

	var test_menu: OptionMenu = %TestsMenu
	for test: Dictionary in _tests:
		test_menu.add_test(test.id, test.path)

	var arguments := {}
	for arg in OS.get_cmdline_user_args():
		if arg.contains("="):
			var key_value := arg.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			arguments[arg.trim_prefix("--")] = ""

	if arguments.has("ticks-per-second"):
		Engine.physics_ticks_per_second = int(arguments["ticks-per-second"])
		%TicksPerSecond.value = Engine.physics_ticks_per_second

	if arguments.has("time-scale"):
		Engine.time_scale = float(arguments["time-scale"])
		%TimeScale.value = Engine.time_scale

	if arguments.has("max-steps-per-frame"):
		Engine.max_physics_steps_per_frame = int(arguments["max-steps-per-frame"])
		%MaxStepsPerFrame.value = Engine.max_physics_steps_per_frame

	if arguments.has("solver-iterations"):
		%SolverIterations.value = int(arguments["solver-iterations"])
		PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS, int(arguments["solver-iterations"]))

	if arguments.has("contact-bias"):
		%ContactBias.value = float(arguments["contact-bias"])
		PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONTACT_DEFAULT_BIAS, float(arguments["contact-bias"]))

	if arguments.has("constraint-bias"):
		%ConstraintBias.value = float(arguments["constraint-bias"])
		PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONSTRAINT_DEFAULT_BIAS, float(arguments["constraint-bias"]))

	if arguments.has("physics-interpolation"):
		var arg: String = arguments["physics_interpolation"].to_lower()
		get_tree().physics_interpolation = arg == "true" or arg == "on"
		%PhysicsInterpolation.button_pressed = get_tree().physics_interpolation

	if arguments.has("test-scene"):
		test_menu.start_test_from_scene.call_deferred(arguments["test-scene"])


func _on_ticks_per_second_value_changed(value: float) -> void:
	%TicksPerSecondValue.text = str(roundi(value * Engine.time_scale))
	Engine.physics_ticks_per_second = roundi(value)


func _on_time_scale_value_changed(value: float) -> void:
	value = maxf(0.1, value)
	%TimeScaleValue.text = "%.1f×" % value
	Engine.time_scale = value
	Engine.physics_ticks_per_second = %TicksPerSecond.value * value
	%TicksPerSecondValue.text = str(roundi(%TicksPerSecond.value * value))


func _on_max_steps_per_frame_value_changed(value: float) -> void:
	%MaxStepsPerFrameValue.text = str(roundi(value))
	Engine.max_physics_steps_per_frame = roundi(value)


func _on_solver_iterations_value_changed(value: float) -> void:
	%SolverIterationsValue.text = str(roundi(value))
	PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS, roundi(value))


func _on_contact_bias_value_changed(value: float) -> void:
	%ContactBiasValue.text = "%.2f" % value
	PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONTACT_DEFAULT_BIAS, value)


func _on_constraint_bias_value_changed(value: float) -> void:
	%ConstraintBiasValue.text = "%.2f" % value
	PhysicsServer2D.space_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONSTRAINT_DEFAULT_BIAS, value)


func _on_physics_interpolation_toggled(toggled_on: bool) -> void:
	get_tree().physics_interpolation = toggled_on


func _get_default_options() -> void:
	%PhysicsInterpolation.button_pressed = get_tree().physics_interpolation
	%ConstraintBias.value = PhysicsServer2D.space_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONSTRAINT_DEFAULT_BIAS)
	%ContactBias.value = PhysicsServer2D.space_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONTACT_DEFAULT_BIAS)
	%SolverIterations.value = PhysicsServer2D.space_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS)
	%MaxStepsPerFrame.value = Engine.max_physics_steps_per_frame
	%TicksPerSecond.value = Engine.physics_ticks_per_second
	%TimeScale.value = Engine.time_scale
