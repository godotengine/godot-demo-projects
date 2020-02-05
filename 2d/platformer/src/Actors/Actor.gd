extends KinematicBody2D
class_name Actor

# Both the Player and Enemy inherit this scene as they have shared behaviours such as
# speed and are affected by gravity.


export var speed = Vector2(400.0, 500.0)
export var gravity = 3500.0

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO

# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	_velocity.y += gravity * delta
