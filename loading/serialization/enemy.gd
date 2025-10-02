class_name Enemy
extends Node2D

## Movement speed in pixels per second.
const MOVEMENT_SPEED = 75.0
const DAMAGE_PER_SECOND = 15.0

## The node we should be "attacking" every frame.
## If [code]null[/code], nobody is in range to attack.
var attacking: Player = null

func _process(delta: float) -> void:
	if is_instance_valid(attacking):
		attacking.health -= delta * DAMAGE_PER_SECOND

	position.x += MOVEMENT_SPEED * delta

	# The enemy went outside of the window. Move it back to the left.
	if position.x >= 732:
		position.x = -32


func _on_attack_area_body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		attacking = body


func _on_attack_area_body_exited(_body: PhysicsBody2D) -> void:
	attacking = null
