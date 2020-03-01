tool
extends Sprite

onready var _fortyFive = preload("res://assets/shadow/textures/fortyfive.png")
onready var _isometric = preload("res://assets/shadow/textures/isometric.png")
onready var _topDown = preload("res://assets/shadow/textures/topdown.png")
onready var _frontSide = preload("res://assets/shadow/textures/frontside.png")
onready var _obliqueY = preload("res://assets/shadow/textures/obliqueY.png")
onready var _obliqueZ = preload("res://assets/shadow/textures/obliqueZ.png")

func _process(_delta):
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


func set_view_mode(view_mode_index):
	match view_mode_index:
		0: # 45 Degrees
			texture = _fortyFive;
		1: # Isometric
			texture = _isometric
		2: # Top Down
			texture = _topDown
		3: # Front Side
			texture = _frontSide
		4: # Oblique Y
			texture = _obliqueY
		5: # Oblique Z
			texture = _obliqueZ
