class_name Coin
extends Area2D
# Collectible that disappears when the player touches it.


onready var animation_player = $AnimationPlayer

# The Coins only detects collisions with the Player thanks to its collision mask.
# This prevents other characters such as enemies from picking up coins.

# When the player collides with a coin, the coin plays its "picked" animation.
# The animation takes cares of making the coin disappear, but also deactivates its
# collisions and frees it from memory, saving us from writing more complex code.
# Click the AnimationPlayer node to see the animation timeline.
func _on_body_entered(_body):
	animation_player.play("picked")
	_body.emit_signal("collect_coin")
