extends Node3D


## Used for checking if the mouse is inside the Area3D.
var is_mouse_inside: bool = false

## The position of the last input event from the *previous* frame, used to
## calculate relative movement for [InputEventMouseMotion] and
## [InputEventScreenDrag] events. See [member record_pos2D] for why this is
## not updated inside the same frame.
var last_event_pos2D := Vector2()

## The time of the last input event from the previous frame, in seconds since
## engine start.
var last_event_time := -1.0

## The frame in which the last update of [member last_event_pos2D] happened.
## Used to ensure [member last_event_pos2D] / [member last_event_time] are only
## refreshed once per frame, so events sharing a frame (e.g. a paired
## [InputEventMouseMotion] / [InputEventScreenDrag] when
## `input_devices/pointing/emulate_touch_from_mouse` is enabled) compute their
## relative motion against the previous frame, not against each other.
var record_frame: int = -1

## The position of the most recent input event in the current frame. Promoted
## into [member last_event_pos2D] on the next frame's first event.
var record_pos2D := Vector2()

## The time of the most recent input event in the current frame. Promoted
## into [member last_event_time] on the next frame's first event.
var record_event_time: float = -1.0

@onready var node_viewport: SubViewport = $SubViewport
@onready var node_quad: MeshInstance3D = $Quad
@onready var node_area: Area3D = $Quad/Area3D


func _ready() -> void:
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	# If the material is NOT set to use billboard settings, then avoid running billboard specific code
	if node_quad.get_surface_override_material(0).billboard_mode == BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED:
		set_process(false)


func _process(_delta: float) -> void:
	# NOTE: Remove this function if you don't plan on using billboard settings.
	rotate_area_to_billboard()


func _mouse_entered_area() -> void:
	is_mouse_inside = true
	# Notify the viewport that the mouse is now hovering it.
	node_viewport.notification(NOTIFICATION_VP_MOUSE_ENTER)


func _mouse_exited_area() -> void:
	# Notify the viewport that the mouse is no longer hovering it.
	node_viewport.notification(NOTIFICATION_VP_MOUSE_EXIT)
	is_mouse_inside = false


func _unhandled_input(input_event: InputEvent) -> void:
	# Check if the event is a non-mouse/non-touch event
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(input_event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	node_viewport.push_input(input_event)


func _mouse_input_event(_camera: Camera3D, input_event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# Get mesh size to detect edges and make conversions. This code only supports PlaneMesh and QuadMesh.
	var quad_mesh_size: Vector2 = node_quad.mesh.size

	# Event position in Area3D in world coordinate space.
	var event_pos3D := event_position

	# Current time in seconds since engine start.
	var now := Time.get_ticks_msec() / 1000.0

	# Convert position to a coordinate space relative to the Area3D node.
	# NOTE: `affine_inverse()` accounts for the Area3D node's scale, rotation, and position in the scene!
	event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

	# TODO: Adapt to bilboard mode or avoid completely.

	var event_pos2D := Vector2()

	if is_mouse_inside:
		# Convert the relative event position from 3D to 2D.
		event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)

		# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
		# We need to convert it into the following range: -0.5 -> 0.5
		event_pos2D.x = event_pos2D.x / quad_mesh_size.x
		event_pos2D.y = event_pos2D.y / quad_mesh_size.y
		# Then we need to convert it into the following range: 0 -> 1
		event_pos2D.x += 0.5
		event_pos2D.y += 0.5

		# Finally, we convert the position to the following range: 0 -> viewport.size
		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y
		# We need to do these conversions so the event's position is in the viewport's coordinate system.

	elif last_event_pos2D != null:
		# Fall back to the last known event position.
		event_pos2D = last_event_pos2D

	# Only promote the staged position/time into last_event_pos2D / last_event_time
	# on the first event of each frame. This way, every event in a frame computes
	# its relative motion against the previous frame's final position, instead of
	# against an earlier event in the same frame (which would zero out the second
	# event's relative motion when several events share a position, as happens
	# with paired InputEventMouseMotion / InputEventScreenDrag from emulated
	# touch).
	var current_frame := Engine.get_process_frames()
	if record_frame != current_frame:
		record_frame = current_frame
		last_event_pos2D = record_pos2D
		last_event_time = record_event_time

	# Stage this event so the next frame's first event sees the most recent
	# position rather than the earliest position of the previous frame.
	record_pos2D = event_pos2D
	record_event_time = now

	# Set the event's position and global position.
	input_event.position = event_pos2D
	if input_event is InputEventMouse:
		input_event.global_position = event_pos2D

	# Calculate the relative event distance.
	if input_event is InputEventMouseMotion or input_event is InputEventScreenDrag:
		# If there is no stored previous position yet, assume no relative motion.
		if last_event_time < 0.0:
			input_event.relative = Vector2(0, 0)
		# Otherwise compute relative motion against the previous frame's final
		# position. This will give us the distance the event traveled since the
		# end of the previous frame.
		else:
			input_event.relative = event_pos2D - last_event_pos2D
			input_event.velocity = input_event.relative / (now - last_event_time)

	# Finally, send the processed input event to the viewport.
	node_viewport.push_input(input_event)


func rotate_area_to_billboard() -> void:
	var billboard_mode: BaseMaterial3D.BillboardMode = node_quad.get_surface_override_material(0).billboard_mode

	# Try to match the area with the material's billboard setting, if enabled.
	if billboard_mode > 0:
		# Get the camera.
		var camera := get_viewport().get_camera_3d()
		# Look in the same direction as the camera.
		var look := camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		look = node_area.position + look

		# Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
		if billboard_mode == 2:
			look = Vector3(look.x, 0, look.z)

		node_area.look_at(look, Vector3.UP)

		# Rotate in the Z axis to compensate camera tilt.
		node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)
