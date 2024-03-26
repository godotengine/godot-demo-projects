# Handles Player-specific behavior like moving. We calculate such things with CharacterBody3D.
extends CharacterBody3D
class_name PlayerMath25D # No icon necessary

var vertical_speed := 0.0
var isometric_controls := true
@onready var _parent_node25d: Node25D = get_parent()

func _physics_process(delta):
	if Input.is_action_pressed(&"exit"):
		get_tree().quit()

	if Input.is_action_just_pressed(&"view_cube_demo"):
		get_tree().change_scene_to_file("res://assets/cube/cube.tscn")
		return

	if Input.is_action_just_pressed(&"toggle_isometric_controls"):
		isometric_controls = not isometric_controls
	if Input.is_action_just_pressed(&"reset_position") or position.y <= -100:
		# Reset player position if the player fell down into the void.
		transform = Transform3D(Basis(), Vector3.UP * 0.5)
		vertical_speed = 0
	else:
		_horizontal_movement(delta)
		_vertical_movement(delta)


# Checks WASD and Shift for horizontal movement via move_and_slide.
func _horizontal_movement(delta):
	var localX = Vector3.RIGHT
	var localZ = Vector3.BACK

	if isometric_controls and is_equal_approx(Node25D.SCALE * 0.86602540378, _parent_node25d.get_basis()[0].x):
		localX = Vector3(0.70710678118, 0, -0.70710678118)
		localZ = Vector3(0.70710678118, 0, 0.70710678118)

	# Gather player input and add directional movement to a Vector3 variable.
	var movement_vec2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var move_dir = localX * movement_vec2.x + localZ * movement_vec2.y

	velocity = move_dir * delta * 1200
	if Input.is_action_pressed(&"movement_modifier"):
		velocity /= 2

	move_and_slide()


# Checks Jump and applies gravity and vertical speed via move_and_collide.
func _vertical_movement(delta):
	var localY = Vector3.UP
	if Input.is_action_just_pressed(&"jump"):
		vertical_speed = 0.55
	vertical_speed -= delta * 2 # Gravity
	var k = move_and_collide(localY * vertical_speed)
	if k != null:
		vertical_speed = 0
