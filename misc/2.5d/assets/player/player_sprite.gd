tool
extends Sprite

onready var _stand = preload("res://assets/player/textures/stand.png")
onready var _jump = preload("res://assets/player/textures/jump.png")
onready var _run = preload("res://assets/player/textures/run.png")

const FRAMERATE = 15

var _direction := 0
var _progress := 0.0
var _parent_node25d: Node25D
var _parent_math: PlayerMath25D

func _ready():
	_parent_node25d = get_parent()
	_parent_math = _parent_node25d.get_child(0)


func _process(delta):
	if Engine.is_editor_hint():
		return # Don't run this in the editor.

	_sprite_basis()
	var movement = _check_movement() # Always run to get direction, but don't always use return bool.

	# Test-only move and collide, check if the player is on the ground.
	var k = _parent_math.move_and_collide(Vector3.DOWN * 10 * delta, true, true, true)
	if k != null:
		if movement:
			hframes = 6
			texture = _run
			if (Input.is_action_pressed("movement_modifier")):
				delta /= 2
			_progress = fmod((_progress + FRAMERATE * delta), 6)
			frame = _direction * 6 + int(_progress)
		else:
			hframes = 1
			texture = _stand
			_progress = 0
			frame = _direction
	else:
		hframes = 2
		texture = _jump
		_progress = 0
		var jumping = 1 if _parent_math.vertical_speed < 0 else 0
		frame = _direction * 2 + jumping


func set_view_mode(view_mode_index):
	match view_mode_index:
		0: # 45 Degrees
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 0.75)
		1: # Isometric
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 1)
		2: # Top Down
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 0.5)
		3: # Front Side
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 1)
		4: # Oblique Y
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0.75, 0.75)
		5: # Oblique Z
			transform.x = Vector2(1, 0.25)
			transform.y = Vector2(0, 1)


# Change the 2D basis of the sprite to try and make it "fit" multiple view modes.
func _sprite_basis():
	if Input.is_action_pressed("forty_five_mode"):
		set_view_mode(0)
	elif Input.is_action_pressed("isometric_mode"):
		set_view_mode(1)
	elif Input.is_action_pressed("top_down_mode"):
		set_view_mode(2)
	elif Input.is_action_pressed("front_side_mode"):
		set_view_mode(3)
	elif Input.is_action_pressed("oblique_y_mode"):
		set_view_mode(4)
	elif Input.is_action_pressed("oblique_z_mode"):
		set_view_mode(5)


# This method returns a bool but if true it also outputs to the direction variable.
func _check_movement() -> bool:
	# Gather player input and store movement to these int variables. Note: These indeed have to be integers.
	var x := 0
	var z := 0

	if Input.is_action_pressed("move_right"):
		x += 1
	if Input.is_action_pressed("move_left"):
		x -= 1
	if Input.is_action_pressed("move_forward"):
		z -= 1
	if Input.is_action_pressed("move_back"):
		z += 1

	# Check for isometric controls and add more to movement accordingly.
	# For efficiency, only check the X axis since this X axis value isn't used anywhere else.
	if !_parent_math.isometric_controls && is_equal_approx(Node25D.SCALE * 0.86602540378, _parent_node25d.get_basis()[0].x):
		if Input.is_action_pressed("move_right"):
			z += 1
		if Input.is_action_pressed("move_left"):
			z -= 1
		if Input.is_action_pressed("move_forward"):
			x += 1
		if Input.is_action_pressed("move_back"):
			x -= 1

	# Set the direction based on which inputs were pressed.
	if x == 0:
		if z == 0:
			return false # No movement.
		elif z > 0:
			_direction = 0
		else:
			_direction = 4
	elif x > 0:
		if z == 0:
			_direction = 2
			flip_h = true
		elif z > 0:
			_direction = 1
			flip_h = true
		else:
			_direction = 3
			flip_h = true
	else:
		if z == 0:
			_direction = 2
			flip_h = false
		elif z > 0:
			_direction = 1
			flip_h = false
		else:
			_direction = 3
			flip_h = false
	return true # There is movement.
