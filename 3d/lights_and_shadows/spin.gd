extends Node3D

var increment := 0.0

func _process(delta: float) -> void:
	position.x = sin(increment)
	position.z = cos(increment)
	# Avoid precision issues over time by rolling over every full turn.
	rotation.y = fmod(increment, TAU)

	increment += delta
