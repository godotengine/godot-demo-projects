extends Node2D


const CAVE_LIMIT = 1000

var glow_map := preload("res://glow_map.webp")

@onready var cave: Node2D = $Cave


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion and input_event.button_mask > 0:
		cave.position.x = clampf(cave.position.x + input_event.screen_relative.x, -CAVE_LIMIT, 0)

	if input_event.is_action_pressed(&"toggle_glow_map"):
		if $WorldEnvironment.environment.glow_map:
			$WorldEnvironment.environment.glow_map = null
			# Restore glow intensity to its default value
			$WorldEnvironment.environment.glow_intensity = 0.8
		else:
			$WorldEnvironment.environment.glow_map = glow_map
			# Increase glow intensity to compensate for the glow map darkening parts of the glow.
			$WorldEnvironment.environment.glow_intensity = 1.6
