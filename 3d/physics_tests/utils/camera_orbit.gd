extends Camera3D

const ROTATION_COEFF = 0.02

var _rotation_enabled := false
var _rotation_pivot: Node3D

func _ready() -> void:
	_initialize_pivot.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_rotation_enabled = event.pressed

		return

	if not _rotation_enabled:
		return

	if event is InputEventMouseMotion:
		var rotation_delta: float = event.relative.x
		_rotation_pivot.rotate(Vector3.UP, -rotation_delta * ROTATION_COEFF)


func _initialize_pivot() -> void:
	_rotation_pivot = Node3D.new()
	var camera_parent := get_parent()
	camera_parent.add_child(_rotation_pivot)
	camera_parent.remove_child(self)
	_rotation_pivot.add_child(self)
