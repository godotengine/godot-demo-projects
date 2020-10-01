extends KinematicBody

var velocity = Vector3()

var _mouse_motion = Vector2()
var _selected_block = 6

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

onready var head = $Head
onready var raycast = $Head/RayCast
onready var selected_block_texture = $SelectedBlock
onready var voxel_world = $"../VoxelWorld"
onready var crosshair = $"../PauseMenu/Crosshair"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	# Mouse movement.
	_mouse_motion.y = clamp(_mouse_motion.y, -1550, 1550)
	transform.basis = Basis(Vector3(0, _mouse_motion.x * -0.001, 0))
	head.transform.basis = Basis(Vector3(_mouse_motion.y * -0.001, 0, 0))

	# Block selection.
	var position = raycast.get_collision_point()
	var normal = raycast.get_collision_normal()
	if Input.is_action_just_pressed("pick_block"):
		# Block picking.
		var block_global_position = (position - normal / 2).floor()
		_selected_block = voxel_world.get_block_global_position(block_global_position)
	else:
		# Block prev/next keys.
		if Input.is_action_just_pressed("prev_block"):
			_selected_block -= 1
		if Input.is_action_just_pressed("next_block"):
			_selected_block += 1
		_selected_block = wrapi(_selected_block, 1, 30)
	# Set the appropriate texture.
	var uv = Chunk.calculate_block_uvs(_selected_block)
	selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	# Block breaking/placing.
	if crosshair.visible and raycast.is_colliding():
		var breaking = Input.is_action_just_pressed("break")
		var placing = Input.is_action_just_pressed("place")
		# Either both buttons were pressed or neither are, so stop.
		if breaking == placing:
			return

		if breaking:
			var block_global_position = (position - normal / 2).floor()
			voxel_world.set_block_global_position(block_global_position, 0)
		elif placing:
			var block_global_position = (position + normal / 2).floor()
			voxel_world.set_block_global_position(block_global_position, _selected_block)


func _physics_process(delta):
	# Crouching.
	var crouching = Input.is_action_pressed("crouch")
	if crouching:
		head.transform.origin = Vector3(0, 1.2, 0)
	else:
		head.transform.origin = Vector3(0, 1.6, 0)

	# Keyboard movement.
	var movement = transform.basis.xform(Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	).normalized() * (1 if crouching else 5))

	# Gravity.
	velocity.y -= gravity * delta

	#warning-ignore:return_value_discarded
	velocity = move_and_slide(Vector3(movement.x, velocity.y, movement.z), Vector3.UP)

	# Jumping, applied next frame.
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = 5


func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_mouse_motion += event.relative


func chunk_pos():
	return (transform.origin / Chunk.CHUNK_SIZE).floor()
