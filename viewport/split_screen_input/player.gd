## Player implementation.
class_name Player
extends CharacterBody2D


const factor: float = 200.0 # Factor to multiply the movement.

var _movement: Vector2 = Vector2(0, 0) # Current movement rate of node.


# Update movement variable based on input that reaches this SubViewport.
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ux_up") or input_event.is_action_released(&"ux_down"):
		_movement.y -= 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_down") or input_event.is_action_released(&"ux_up"):
		_movement.y += 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_left") or input_event.is_action_released(&"ux_right"):
		_movement.x -= 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_right") or input_event.is_action_released(&"ux_left"):
		_movement.x += 1
		get_viewport().set_input_as_handled()


# Move the node based on the content of the movement variable.
func _physics_process(delta: float) -> void:
	move_and_collide(_movement * factor * delta)
