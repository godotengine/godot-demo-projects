extends CharacterBody3D

const MOUSE_SENSITIVITY = 2.5
const CAMERA_SMOOTH_SPEED = 10.0
const MOVE_SPEED = 3.0
const FRICTION = 10.0
const JUMP_VELOCITY = 8.0
const BULLET_SPEED = 9.0

var _yaw := 0.0
var _pitch := 0.0
var _dir := Vector3(sin(_yaw), 0, cos(_yaw))
var _prox := 3

var _tps_look_from := Vector3()

enum CameraType {
	CAM_FIXED,
	CAM_FPS,
	CAM_TPS,
}

var _bullet_scene: PackedScene = load("res://bullet.tscn")
var _cam_type := CameraType.CAM_FIXED

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Rig/Camera_TPS.top_level = true
	cycle_camera_type()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.screen_relative.x * MOUSE_SENSITIVITY * 0.001
		_pitch += event.screen_relative.y * MOUSE_SENSITIVITY * 0.002
		_pitch = clamp(_pitch, -PI, PI)
		$Rig.rotation = Vector3(0, _yaw, 0)


func _update_camera(delta: float) -> void:
		_dir.x = sin(_yaw)
		_dir.z = cos(_yaw)

		$Rig/Head.rotation = Vector3(_pitch * -0.5, 0, 0)

		match _cam_type:
			CameraType.CAM_TPS:
				var target: Vector3 = $Rig/Head.get_global_transform_interpolated().origin
				var pos := target
				pos.x += _dir.x * _prox
				pos.z += _dir.z * _prox
				pos.y += 2.0 + (_pitch * (0.2 * _prox))

				var offset: Vector3 = pos - _tps_look_from
				var l: float = offset.length()

				var tps_cam_speed: float = CAMERA_SMOOTH_SPEED * delta
				if (l > tps_cam_speed):
					offset *= tps_cam_speed / l
				_tps_look_from += offset

				$Rig/Camera_TPS.look_at_from_position(_tps_look_from, target, Vector3(0, 1, 0))


func cycle_camera_type() -> void:
	match _cam_type:
		CameraType.CAM_FIXED:
			_cam_type = CameraType.CAM_FPS
			$Rig/Head/Camera_FPS.make_current()
		CameraType.CAM_FPS:
			_cam_type = CameraType.CAM_TPS
			$Rig/Camera_TPS.make_current()
		CameraType.CAM_TPS:
			_cam_type = CameraType.CAM_FIXED
			get_node("../Camera_Fixed").make_current()

	# Hide body in FPS view (but keep shadow casting to improve spatial awareness).
	if _cam_type == CameraType.CAM_FPS:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	else:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"cycle_camera_type"):
		cycle_camera_type()

	if Input.is_action_just_pressed(&"toggle_physics_interpolation"):
		get_tree().physics_interpolation = not get_tree().physics_interpolation

	if Input.is_action_just_pressed(&"fire"):
		var bullet: RigidBody3D = _bullet_scene.instantiate()
		var transform_3d: Transform3D = $Rig/Head/Fire_Origin.get_global_transform_interpolated()
		bullet.position = transform_3d.origin
		var bul_dir: Vector3 = transform_3d.basis[2].normalized()
		bullet.linear_velocity = bul_dir * -BULLET_SPEED
		get_parent().add_child(bullet)
		bullet.reset_physics_interpolation()

		bullet.position -= bul_dir * (1.0 - Engine.get_physics_interpolation_fraction())


	# If we pressed reset, or too far from the origin... move back to origin.
	if Input.is_action_just_pressed(&"reset_position") or position.length() > 10.0:
		position = Vector3(0, 1, 0)
		velocity = Vector3()
		reset_physics_interpolation()
		_yaw = 0.0
		_pitch = 0.0
		$Rig.rotation = Vector3(0, _yaw, 0)

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	_update_camera(delta)


func _physics_process(delta: float) -> void:
	var move := Vector3()

	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward") * MOVE_SPEED
	move.x = input.x
	move.z = input.y

	# Apply gravity.
	move.y -= gravity * delta

	# Apply mouse rotation to the move.
	move = move.rotated(Vector3(0, 1, 0), _yaw)

	velocity += move

	move_and_slide()

	# Apply friction to horizontal motion in a tick rate-independent manner.
	var friction_delta := exp(-FRICTION * delta)
	velocity = Vector3(velocity.x * friction_delta, velocity.y, velocity.z * friction_delta)
