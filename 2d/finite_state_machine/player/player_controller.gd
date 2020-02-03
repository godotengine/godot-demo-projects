extends KinematicBody2D
# The Player is a KinematicBody2D, in other words a physics-driven object.
# It can move, collide with the world, etc...
# The player has a state machine, but the body and the state machine are separate.

signal direction_changed(new_direction)

var look_direction = Vector2.RIGHT setget set_look_direction

func take_damage(attacker, amount, effect = null):
	if is_a_parent_of(attacker):
		return
	$States/Stagger.knockback_direction = (attacker.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)


func set_dead(value):
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = value


func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)
