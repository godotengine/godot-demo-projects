extends RigidBody3D

@onready var raycast = $RayCast3D
@onready var camera = $Target/Camera3D
@onready var start_position = position

func _physics_process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset_position"):
		position = start_position
		return

	var dir = Vector3()
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.z = Input.get_axis(&"move_forward", &"move_back")

	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
	var cam_basis = camera.global_transform.basis
	var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = basis * (dir)

	apply_central_impulse(dir.normalized() / 10)

	# Jumping code.
	if on_ground() and Input.is_action_pressed("jump"):
		apply_central_impulse(Vector3.UP)


# Test if there is a body below the player.
func on_ground():
	if raycast.is_colliding():
		return true


func _on_tcube_body_entered(body):
	if body == self:
		get_node(^"WinText").show()
