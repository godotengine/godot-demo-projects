## Enemy entities with physics-based movement
## See README: Node Inheritance & Types
## RigidBody2D provides physics simulation for realistic movement
extends RigidBody2D

func _ready():
	## See README: Random animations - Cosmetic only
	## Picks random mob type for visual variety, hitbox is same for all
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

func _on_VisibilityNotifier2D_screen_exited():
	## See README: Memory management
	## Frees mob from memory when it leaves screen to avoid performance issues
	queue_free()
