extends Label


var is_compatibility: bool = false


func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		is_compatibility = true
		text = "Space: Pause/Resume\nG: Toggle glow\n\n\n"
		get_parent().get_node(^"UnsupportedLabel").visible = true
		# Increase glow intensity to compensate for lower dynamic range.
		get_node(^"../..").environment.glow_intensity = 4.0


func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_pause"):
		get_tree().paused = not get_tree().paused

	if not is_compatibility and input_event.is_action_pressed(&"toggle_trails"):
		# Particles disappear if trail type is changed while paused.
		# Prevent changing particle type while paused to avoid confusion.
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_enabled = not particles.trail_enabled

	if not is_compatibility and input_event.is_action_pressed(&"increase_trail_length"):
		# Particles disappear if trail type is changed while paused.
		# Prevent changing particle type while paused to avoid confusion.
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_lifetime = clampf(particles.trail_lifetime + 0.05, 0.1, 1.0)

	if not is_compatibility and input_event.is_action_pressed(&"decrease_trail_length"):
		# Particles disappear if trail type is changed while paused.
		# Prevent changing particle type while paused to avoid confusion.
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_lifetime = clampf(particles.trail_lifetime - 0.05, 0.1, 1.0)

	if input_event.is_action_pressed(&"toggle_glow"):
		get_node(^"../..").environment.glow_enabled = not get_node(^"../..").environment.glow_enabled
