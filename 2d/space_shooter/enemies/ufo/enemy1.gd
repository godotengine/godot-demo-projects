extends Area2D

# how many points does the player get for destroying this ship?
const POINTS = 5

var destroyed = false

# used to notify listeners about this enemy's death
signal enemy_died(score)

func _ready():
	# the ship will start its zigzag movement at a random offset in its animation path
	# this skip is visible for about one frame
	# as a workaround, we hide the node until the animation seeking is later completed
	hide()

func destroy():
	# skip if already destroyed
	if (destroyed):
		return

	# set the state to destroyed
	destroyed = true
	# play on-death effects
	# take note of how the explode animation also frees the parent node after 0.9 seconds
	get_node("anim").play("explode")
	get_node("sfx").play("sound_explode")
	# inform listeners about death, while sending the point value along with it
	emit_signal("enemy_died", POINTS)
	# disable physics interactions
	call_deferred("set_enable_monitoring", false)
	call_deferred("set_monitorable", false)

# this signal is connected in the editor
func _on_visibility_enter_screen():
	get_node("anim").play("zigzag")
	 # randomly offset the animation's start point
	get_node("anim").seek(randf()*2.0)
	# as mentioned in _ready, show the node after seeking to the random start point in the animation
	show()
