extends Area2D

# horizontal movement speed
const SPEED = -200

# how many points does the player get for destroying this enemy type?
const POINTS = 1

# used for a slight vertical drift, defines the range
const Y_RANDOM = 10

# vertical movement for this asteroid instance
var speed_y = 0.0

# used to store this asteroid's motion direction
var motion = Vector2()

var destroyed = false

# notifies listeners about death and sends the point value along with it
signal enemy_died(score)

func _fixed_process(delta):
	# constant movement
	translate(motion * delta)

func _ready():
	# determine this asteroid's vertical drift
	speed_y = rand_range(-Y_RANDOM, Y_RANDOM)
	# store the movement direction because it doesn't change for this asteroid
	motion = Vector2(SPEED, speed_y)

func destroy():
	# skip if already destroyed
	if (destroyed):
		return
	
	# set the state to destroyed
	destroyed = true
	# stop processing
	set_fixed_process(false)
	# play on-death effects
	get_node("anim").play("explode")
	get_node("sfx").play("sound_explode")
	# inform listeners about death, while sending the point value along with it
	emit_signal("enemy_died", POINTS)
	# disable physics interactions
	call_deferred("set_enable_monitoring", false)
	call_deferred("set_monitorable", false)

func _on_visibility_enter_screen():
	# start moving once the asteroid enters the screen
	set_fixed_process(true)
	# Make it spin!
	get_node("anim").play("spin")

func _on_visibility_exit_screen():
	# remove the asteroid when it leaves the screen
	queue_free()
