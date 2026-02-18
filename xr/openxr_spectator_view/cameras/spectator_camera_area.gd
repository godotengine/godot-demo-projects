extends Area3D

@export var interaction_action: String = "interact"

var _parent_camera: Camera3D
var _current_pointer: XRPointer
var _controller: XRController3D
var _was_pos: Vector3

# Find the XRController3D ancester of the given node.
func _get_controller(node: Node3D) -> XRController3D:
	var parent = node.get_parent()
	while parent:
		if parent is XRController3D:
			return parent
		parent = parent.get_parent()
	return null


# Called when the node enters the scene tree for the first time.
func _ready():
	_parent_camera = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not _parent_camera:
		return

	# If we don't have a controller, let's see if we can find one!
	if not _controller:
		# If nothing is pointing at us, we have nothing to do!
		if not _current_pointer:
			return

		# Find our related controller
		var controller = _get_controller(_current_pointer)
		if controller:
			if not controller.is_button_pressed(interaction_action):
				return

			# We "capture" this controller, even if the pointer leaves
			# we keep using this controller until the user releases the button.
			_controller = controller

			var plane: Plane = Plane(global_basis.z, global_position)
			_was_pos = plane.intersects_ray(_controller.global_position, -_controller.global_basis.z)
	else:
		if not _controller.is_button_pressed(interaction_action):
			_controller = null
			return

		var plane: Plane = Plane(global_basis.z, global_position)
		var new_pos = plane.intersects_ray(_controller.global_position, -_controller.global_basis.z)

		var movement = new_pos - _was_pos
		_was_pos = new_pos

		movement = global_basis.inverse() * movement
		movement *= Vector3(1.0, 1.0, 0.0)
		_parent_camera.global_position += global_basis * movement


# A pointer is touching our area.
func _enter_pointer(pointer: XRPointer, _at: Vector3) -> void:
	_current_pointer = pointer


# A pointer is no longer touching our area.
func _exit_pointer(pointer: XRPointer, _at: Vector3) -> void:
	if _current_pointer == pointer:
		_current_pointer = null
