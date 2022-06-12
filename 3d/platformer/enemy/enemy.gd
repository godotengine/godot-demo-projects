extends RigidBody

const ACCEL = 5.0
const DEACCEL = 20.0
const MAX_SPEED = 2.0
const ROT_SPEED = 1.0

var prev_advance = false
var dying = false
var rot_dir = 4

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func _integrate_forces(state):
	var delta = state.get_step()
	var lv = state.get_linear_velocity()
	var g = state.get_total_gravity()
	# get_total_gravity returns zero for the first few frames, leading to errors.
	if g == Vector3.ZERO:
		g = gravity

	lv += g * delta # Apply gravity.
	var up = -g.normalized()

	if dying:
		state.set_linear_velocity(lv)
		return

	for i in range(state.get_contact_count()):
		var cc = state.get_contact_collider_object(i)
		var dp = state.get_contact_local_normal(i)

		if cc:
			if cc is preload("res://player/bullet/bullet.gd") and cc.enabled:
				set_mode(MODE_RIGID)
				dying = true
				state.set_angular_velocity(-dp.cross(up).normalized() * 33.0)
				get_node("AnimationPlayer").play("impact")
				get_node("AnimationPlayer").queue("explode")
				cc.enabled = false
				get_node("SoundHit").play()
				return

	var col_floor = get_node("Armature/RayFloor").is_colliding()
	var col_wall = get_node("Armature/RayWall").is_colliding()

	var advance = col_floor and not col_wall

	var dir = get_node("Armature").get_transform().basis[2].normalized()
	var deaccel_dir = dir

	if advance:
		if dir.dot(lv) < MAX_SPEED:
			lv += dir * ACCEL * delta
		deaccel_dir = dir.cross(g).normalized()
	else:
		if prev_advance:
			rot_dir = 1

		dir = Basis(up, rot_dir * ROT_SPEED * delta).xform(dir)
		get_node("Armature").set_transform(Transform().looking_at(-dir, up))

	var dspeed = deaccel_dir.dot(lv)
	dspeed -= DEACCEL * delta
	if dspeed < 0:
		dspeed = 0

	lv = lv - deaccel_dir * deaccel_dir.dot(lv) + deaccel_dir * dspeed

	state.set_linear_velocity(lv)
	prev_advance = advance


func _die():
	queue_free()
