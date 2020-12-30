extends KinematicBody2D

const MOVE_SPEED = 75
const DAMAGE_PER_SECOND = 15

# The node we should be "attacking" every frame.
# If `null`, nobody is in range to attack.
var attacking = null


func _process(delta):
	if attacking:
		attacking.health -= delta * DAMAGE_PER_SECOND

	# warning-ignore:return_value_discarded
	move_and_slide(Vector2(MOVE_SPEED, 0))

	# The enemy went outside of the window. Move it back to the left.
	if position.x >= 732:
		position.x = -32


func _on_AttackArea_body_entered(body):
	if body.name == "Player":
		attacking = body


func _on_AttackArea_body_exited(_body):
	attacking = null
