extends Area2D

# Member variables
const SPEED = 200
const SHOT_COOLDOWN = 0.16

const Shot = preload("res://player/shot.tscn")

var screen_size
var killed = false
var can_shoot = true

var shot_timer = 0

var projectile_container

onready var shot_anchor = get_node("shoot_from")

signal player_died

func _fixed_process(delta):
	var motion = Vector2()
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		motion += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
	var shooting = Input.is_action_pressed("shoot")

	var pos = get_pos()

	# normally you would normalize the motion vector using motion.normalized(), so diagonal movement isn't faster
	# in this case, the base speed would make dodging the tilemap impossible in some places
	# additionally, it could be explained as the ship using both horizontal and vertical thrusters at once
	# the better solution in the long run would be to playtest the level and make sure that every passage is playable
	# pos += motion.normalized() * delta * SPEED
	pos += motion * delta * SPEED

	# limit the resulting position to the screen's dimensions, so the player can't fly off screen
	pos.x = clamp(pos.x, 0, screen_size.x)
	pos.y = clamp(pos.y, 0, screen_size.y)

	set_pos(pos)

	# tick down the shot cooldown
	if shot_timer > 0.0:
		shot_timer -= delta

	# the player can shoot if the timer is back to zero
	can_shoot = shot_timer <= 0.0

	# if the player is alive, allowed to shoot and pressing space to shoot..
	if (can_shoot and shooting and not killed):
		# instance a shot
		var shot = Shot.instance()
		# Use the Position2D named "shoot_from" as reference
		shot.set_pos(shot_anchor.get_global_pos())
		# add the shot to projectile container so it moves independently from the ship
		if projectile_container != null:
			projectile_container.add_child(shot)
			# Play sound
			get_node("sfx").play("shoot")
			# delay the next shot
			shot_timer = SHOT_COOLDOWN

func _ready():
	screen_size = get_viewport().get_rect().size
	set_fixed_process(true)

func _hit_something():
	if (killed):
		return
	killed = true
	# disable the collider
	call_deferred("set_enable_monitoring", false)
	call_deferred("set_monitorable", false)
	# play on-death effects
	get_node("anim").play("explode")
	get_node("sfx").play("sound_explode")
	# notify listeners that the player died
	emit_signal("player_died")
	# disable processing
	set_fixed_process(false)

# the block tiles in a level have StaticBody2D colliders, touching them kills the player ship
func _on_ship_body_enter(body):
	_hit_something()

# colliding with the area of an enemy (asteroid, enemy1, enemy2 scenes) kills the player ship
func _on_ship_area_enter(area):
	# check if the colliding node is in the "enemy" node group
	if area.is_in_group("enemy"):
		_hit_something()

# setup function to obtain a reference to the bullet container node
func set_projectile_container(container):
	projectile_container = container

# other objects (enemy projectiles) use this to tell the player ship that it was hit
func take_damage():
	_hit_something()
