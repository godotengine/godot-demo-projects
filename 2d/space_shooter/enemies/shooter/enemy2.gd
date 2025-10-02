extends Area2D

# horizontal movement speed
const SPEED = -220

# how many points does the player get for destroying this ship?
const POINTS = 10

# time between shots in seconds
const SHOOT_INTERVAL = 1

# the enemy's projectile scene
const Shot = preload("res://enemies/shooter/enemy_shot.tscn")

# used to store this enemy's motion direction
var motion = Vector2()

var destroyed = false

# remaining timeout until the enemy can fire again
var shoot_timeout = 0

# the node in the tree where this enemy should spawn its bullets into
var projectile_container

# the Position2D that defines where the bullets will be spawned
onready var shoot_from = get_node("shoot_from")

# used to notify listeners about this enemy's death
signal enemy_died(score)

func _ready():
	motion = Vector2(SPEED, 0)

func _fixed_process(delta):
	# the enemy constantly moves
	translate(motion * delta)

	# count down the time until the next shot
	if shoot_timeout > 0.0:
		shoot_timeout -= delta

	if (shoot_timeout <= 0):
		shoot_timeout = SHOOT_INTERVAL

		if projectile_container != null:
			# Instance a shot
			var shot = Shot.instance()
			# Set position to "shoot_from" Position2D node's global position
			shot.set_pos(shoot_from.get_global_pos())
			# Add it to the projectile container, making its movement independent from ours
			projectile_container.add_child(shot)

func set_projectile_container(container):
	projectile_container = container

func destroy():
	# skip if already destroyed
	if (destroyed):
		return
	destroyed = true

	# stop processing
	set_fixed_process(false)
	# play on-death effects
	get_node("sfx").play("sound_explode")
	get_node("anim").play("explode")
	# inform listeners about death, while sending the point value along with it
	emit_signal("enemy_died", POINTS)
	call_deferred("set_enable_monitoring", false)
	call_deferred("set_monitorable", false)

func _on_visibility_enter_screen():
	set_fixed_process(true)

func _on_visibility_exit_screen():
	queue_free()
