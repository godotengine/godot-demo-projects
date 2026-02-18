class_name XRPointer
extends RayCast3D


var pointing_at: Node3D
var colliding_at: Vector3 = Vector3()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Laser.visible = enabled

	var col_with: Node3D
	var col_at: Vector3 = Vector3()

	if enabled:
		if is_colliding():
			col_with = get_collider()
			col_at = get_collision_point()
			$Target.global_position = col_at
			$Target.visible = true
		else:
			$Target.visible = false
	else:
		$Target.visible = false

	if pointing_at and pointing_at != col_with:
		if pointing_at.has_method(&"_exit_pointer"):
			pointing_at._exit_pointer(self, colliding_at)
		pointing_at = null

	if col_with and not pointing_at:
		pointing_at = col_with
		colliding_at = col_at
		if pointing_at.has_method(&"_enter_pointer"):
			pointing_at._enter_pointer(self, colliding_at)

	if pointing_at and colliding_at != col_at:
		if pointing_at.has_method(&"_moved_pointer"):
			pointing_at._moved_pointer(self, colliding_at, col_at)
		colliding_at = col_at
