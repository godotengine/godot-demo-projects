class_name Player
extends RigidBody2D

const WALK_ACCEL = 1000.0
const WALK_DEACCEL = 1000.0
const WALK_MAX_VELOCITY = 200.0
const AIR_ACCEL = 250.0
const AIR_DEACCEL = 250.0
const JUMP_VELOCITY = 380.0
const STOP_JUMP_FORCE = 450.0
const MAX_SHOOT_POSE_TIME = 0.3
const MAX_FLOOR_AIRBORNE_TIME = 0.15

const BULLET_SCENE = preload("res://player/bullet.tscn")
const ENEMY_SCENE = preload("res://enemy/enemy.tscn")

var anim := ""
var siding_left := false
var jumping := false
var stopping_jump := false
var shooting := false

var floor_h_velocity: float = 0.0

var airborne_time: float = 1e20
var shoot_time: float = 1e20

@onready var sound_jump := $SoundJump as AudioStreamPlayer2D
@onready var sound_shoot := $SoundShoot as AudioStreamPlayer2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var sprite_smoke := sprite.get_node(^"Smoke") as CPUParticles2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var bullet_shoot := $BulletShoot as Marker2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
	var step := state.get_step()

	var new_anim := anim
	var new_siding_left := siding_left

	# Get player input.
	var move_left := Input.is_action_pressed(&"move_left")
	var move_right := Input.is_action_pressed(&"move_right")
	var jump := Input.is_action_pressed(&"jump")
	var shoot := Input.is_action_pressed(&"shoot")
	var spawn := Input.is_action_just_pressed(&"spawn")

	if spawn:
		_spawn_enemy_above.call_deferred()

	# Deapply previous floor velocity.
	velocity.x -= floor_h_velocity
	floor_h_velocity = 0.0

	# Find the floor (a contact with upwards facing collision normal).
	var found_floor := false
	var floor_index := -1

	for contact_index in state.get_contact_count():
		var collision_normal := state.get_contact_local_normal(contact_index)

		if collision_normal.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = contact_index

	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	if shoot and not shooting:
		_shot_bullet.call_deferred()
	else:
		shoot_time += step

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air.

	var on_floor := airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump.
	if jumping:
		if velocity.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			velocity.y += STOP_JUMP_FORCE * step

	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			if velocity.x > -WALK_MAX_VELOCITY:
				velocity.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if velocity.x < WALK_MAX_VELOCITY:
				velocity.x += WALK_ACCEL * step
		else:
			var xv := absf(velocity.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			velocity.x = signf(velocity.x) * xv

		# Check jump.
		if not jumping and jump:
			velocity.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
			sound_jump.play()

		# Check siding.
		if velocity.x < 0 and move_left:
			new_siding_left = true
		elif velocity.x > 0 and move_right:
			new_siding_left = false
		if jumping:
			new_anim = "jumping"
		elif absf(velocity.x) < 0.1:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "idle_weapon"
			else:
				new_anim = "idle"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "run_weapon"
			else:
				new_anim = "run"
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if velocity.x > -WALK_MAX_VELOCITY:
				velocity.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if velocity.x < WALK_MAX_VELOCITY:
				velocity.x += AIR_ACCEL * step
		else:
			var xv := absf(velocity.x)
			xv -= AIR_DEACCEL * step

			if xv < 0:
				xv = 0
			velocity.x = signf(velocity.x) * xv

		if velocity.y < 0:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "jumping_weapon"
			else:
				new_anim = "jumping"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "falling_weapon"
			else:
				new_anim = "falling"

	# Update siding.
	if new_siding_left != siding_left:
		if new_siding_left:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1

		siding_left = new_siding_left

	# Change animation.
	if new_anim != anim:
		anim = new_anim
		animation_player.play(anim)

	shooting = shoot

	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		velocity.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)


func _shot_bullet() -> void:
	shoot_time = 0
	var bullet := BULLET_SCENE.instantiate() as RigidBody2D
	var speed_scale: float
	if siding_left:
		speed_scale = -1.0
	else:
		speed_scale = 1.0

	bullet.position = position + bullet_shoot.position * Vector2(speed_scale, 1.0)
	get_parent().add_child(bullet)

	bullet.linear_velocity = Vector2(400.0 * speed_scale, -40)

	sprite_smoke.restart()
	sound_shoot.play()

	add_collision_exception_with(bullet) # Make bullet and this not collide.


func _spawn_enemy_above() -> void:
	var enemy := ENEMY_SCENE.instantiate() as RigidBody2D
	enemy.position = position + 50 * Vector2.UP
	get_parent().add_child(enemy)
