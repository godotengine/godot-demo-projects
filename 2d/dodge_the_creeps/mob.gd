## Extends (or inherits) RigidBody2D to have physics simulation 
extends RigidBody2D

## Called when the node enters the scene tree for the first time.
## we randomize the mob type and start its animation.
## It's only cosmetic by the way.
## the hitbox and behavior are the same for all mob types.
func _ready():
	## To make it Random, we get all animation names
	## from the AnimatedSprite2D's SpriteFrames resource
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	## Pick a random mob type from the available animations
	## using the pick_random() method of the Array class.
	$AnimatedSprite2D.animation = mob_types.pick_random()
	## Start playing the animation.
	## Otherwise the mob will not animate.
	$AnimatedSprite2D.play()


## Called when the mob exits the screen.
## Again we use a signal function connected to the VisibilityNotifier2D node.
## This is to free up memory and resources.
## When the mob goes off-screen, we don't need it anymore.
func _on_VisibilityNotifier2D_screen_exited():
	## We call queue_free() to remove it properly.
	queue_free()
