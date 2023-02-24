class_name Actor
extends CharacterBody2D

## Both the Player and Enemy inherit this scene as they have shared behaviours
## such as speed and are affected by gravity.


const FLOOR_NORMAL = Vector2.UP

@export var speed = Vector2(150.0, 350.0)

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity")


## Apply gravity to current velocity
## This should be called in _physics_process of child classes (Player and Enemy)
## so they are affected by gravity.
func apply_gravity(delta):
	velocity.y += gravity * delta
