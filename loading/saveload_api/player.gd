extends Node2D
class_name Player

@export var move_speed : float = 100.0 #pixels per second
@export var turn_rate : float = 1.0 #radians per second

func _process(delta : float) -> void:
	if Input.is_action_pressed("turn_left"):
		rotate(-turn_rate * delta)
	if Input.is_action_pressed("turn_right"):
		rotate(turn_rate * delta)
	if Input.is_action_pressed("move_up"):
		translate(Vector2(0, -move_speed * delta).rotated(rotation))
	if Input.is_action_pressed("move_down"):
		translate(Vector2(0, move_speed * delta).rotated(rotation))
