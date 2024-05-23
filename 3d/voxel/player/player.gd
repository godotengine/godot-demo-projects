extends CharacterBody3D

const EYE_HEIGHT_STAND = 1.6
const EYE_HEIGHT_CROUCH = 1.4

const MOVEMENT_SPEED_GROUND = 0.6
const MOVEMENT_SPEED_AIR = 0.11
const MOVEMENT_SPEED_CROUCH_MODIFIER = 0.5
const MOVEMENT_FRICTION_GROUND = 0.9
const MOVEMENT_FRICTION_AIR = 0.98

var _mouse_motion := Vector2()
var _selected_block := 6

@onready var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

@onready var head: Node3D = $Head
@onready var raycast: RayCast3D = $Head/RayCast3D
@onready var camera_attributes: CameraAttributes = $Head/Camera3D.attributes
@onready var selected_block_texture: TextureRect = $SelectedBlock
@onready var voxel_world: Node = $"../VoxelWorld"
@onready var crosshair: CenterContainer = $"../PauseMenu/Crosshair"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	# Mouse movement.
	_mouse_motion.y = clampf(_mouse_motion.y, -1560, 1560)
	transform.basis = Basis.from_euler(Vector3(0, _mouse_motion.x * -0.001, 0))
	head.transform.basis = Basis.from_euler(Vector3(_mouse_motion.y * -0.001, 0, 0))

	# Block selection.
	var ray_position := raycast.get_collision_point()
	var ray_normal := raycast.get_collision_normal()
	if Input.is_action_just_pressed(&"pick_block"):
		# Block picking.
		var block_global_position := Vector3i((ray_position - ray_normal / 2).floor())
		_selected_block = voxel_world.get_block_global_position(block_global_position)
	else:
		# Block prev/next keys.
		if Input.is_action_just_pressed(&"prev_block"):
			_selected_block -= 1
		if Input.is_action_just_pressed(&"next_block"):
			_selected_block += 1
		_selected_block = wrapi(_selected_block, 1, 30)
	# Set the appropriate texture.
	var uv := Chunk.calculate_block_uvs(_selected_block)
	selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	# Block breaking/placing.
	if crosshair.visible and raycast.is_colliding():
		var breaking := Input.is_action_just_pressed(&"break")
		var placing := Input.is_action_just_pressed(&"place")
		# Either both buttons were pressed or neither are, so stop.
		if breaking == placing:
			return

		if breaking:
			var block_global_position := Vector3i((ray_position - ray_normal / 2).floor())
			voxel_world.set_block_global_position(block_global_position, 0)
		elif placing:
			var block_global_position := Vector3i((ray_position + ray_normal / 2).floor())
			voxel_world.set_block_global_position(block_global_position, _selected_block)


func _physics_process(delta: float) -> void:
	camera_attributes.dof_blur_far_enabled = Settings.fog_enabled
	camera_attributes.dof_blur_far_distance = Settings.fog_distance * 1.5
	camera_attributes.dof_blur_far_transition = Settings.fog_distance * 0.125
	# Crouching.
	var crouching := Input.is_action_pressed(&"crouch")
	head.transform.origin.y = lerpf(head.transform.origin.y, EYE_HEIGHT_CROUCH if crouching else EYE_HEIGHT_STAND, 16 * delta)

	# Keyboard movement.
	var movement_vec2 := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var movement := transform.basis * (Vector3(movement_vec2.x, 0, movement_vec2.y))

	if is_on_floor():
		movement *= MOVEMENT_SPEED_GROUND
	else:
		movement *= MOVEMENT_SPEED_AIR

	if crouching:
		movement *= MOVEMENT_SPEED_CROUCH_MODIFIER

	# Gravity.
	velocity.y -= gravity * delta

	velocity += Vector3(movement.x, 0, movement.z)
	# Apply horizontal friction.
	velocity.x *= MOVEMENT_FRICTION_GROUND if is_on_floor() else MOVEMENT_FRICTION_AIR
	velocity.z *= MOVEMENT_FRICTION_GROUND if is_on_floor() else MOVEMENT_FRICTION_AIR
	move_and_slide()

	# Jumping, applied next frame.
	if is_on_floor() and Input.is_action_pressed(&"jump"):
		velocity.y = 7.5


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_mouse_motion += event.relative


func chunk_pos() -> Vector3i:
	return Vector3i((transform.origin / Chunk.CHUNK_SIZE).floor())
