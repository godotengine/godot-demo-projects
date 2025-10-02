extends RigidBody3D

const ACCEL = 5.0
const DEACCEL = 20.0
const MAX_SPEED = 2.0
const ROT_SPEED = 1.0

var prev_advance := false
var dying := false
var rot_dir := 4

@onready var gravity := Vector3(
		ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
)

@onready var _animation_player := $Enemy/AnimationPlayer as AnimationPlayer
@onready var _ray_floor := $Enemy/Skeleton/RayFloor as RayCast3D
@onready var _ray_wall := $Enemy/Skeleton/RayWall as RayCast3D

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var delta := state.get_step()
	var lin_velocity := state.get_linear_velocity()
	var grav := state.get_total_gravity()
	# get_total_gravity returns zero for the first few frames, leading to errors.
	if grav.is_zero_approx():
		grav = gravity

	lin_velocity += grav * delta # Apply gravity.
	var up := -grav.normalized()

	if dying:
		state.set_linear_velocity(lin_velocity)
		return

	for i in state.get_contact_count():
		var contact_collider := state.get_contact_collider_object(i)
		var contact_normal := state.get_contact_local_normal(i)

		if is_instance_valid(contact_collider):
			if contact_collider is Bullet and contact_collider.enabled:
				dying = true
				axis_lock_angular_x = false
				axis_lock_angular_y = false
				axis_lock_angular_z = false
				collision_layer = 0
				state.set_angular_velocity(-contact_normal.cross(up).normalized() * 33.0)
				_animation_player.play(&"impact")
				_animation_player.queue(&"extra/explode")
				contact_collider.enabled = false
				$SoundWalkLoop.stop()
				$SoundHit.play()
				return

	var advance := _ray_floor.is_colliding() and not _ray_wall.is_colliding()

	var dir := ($Enemy/Skeleton as Node3D).get_transform().basis[2].normalized()
	var deaccel_dir := dir

	if advance:
		if dir.dot(lin_velocity) < MAX_SPEED:
			lin_velocity += dir * ACCEL * delta
		deaccel_dir = dir.cross(gravity).normalized()
	else:
		if prev_advance:
			rot_dir = 1

		dir = Basis(up, rot_dir * ROT_SPEED * (delta)) * dir
		$Enemy/Skeleton.set_transform(Transform3D().looking_at(-dir, up))

	var dspeed := deaccel_dir.dot(lin_velocity)
	dspeed -= DEACCEL * delta
	if dspeed < 0:
		dspeed = 0

	lin_velocity = lin_velocity - deaccel_dir * deaccel_dir.dot(lin_velocity) \
			+ deaccel_dir * dspeed

	state.set_linear_velocity(lin_velocity)
	prev_advance = advance


func _die() -> void:
	queue_free()
