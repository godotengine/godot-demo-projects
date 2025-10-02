@tool
extends Sprite2D

@onready var _forty_five: Texture2D = preload("res://assets/platform/textures/forty_five.png")
@onready var _isometric: Texture2D = preload("res://assets/platform/textures/isometric.png")
@onready var _top_down: Texture2D = preload("res://assets/platform/textures/top_down.png")
@onready var _front_side: Texture2D = preload("res://assets/platform/textures/front_side.png")
@onready var _oblique_y: Texture2D = preload("res://assets/platform/textures/oblique_y.png")
@onready var _oblique_z: Texture2D = preload("res://assets/platform/textures/oblique_z.png")

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_pressed(&"forty_five_mode"):
			set_view_mode(0)
		elif Input.is_action_pressed(&"isometric_mode"):
			set_view_mode(1)
		elif Input.is_action_pressed(&"top_down_mode"):
			set_view_mode(2)
		elif Input.is_action_pressed(&"front_side_mode"):
			set_view_mode(3)
		elif Input.is_action_pressed(&"oblique_y_mode"):
			set_view_mode(4)
		elif Input.is_action_pressed(&"oblique_z_mode"):
			set_view_mode(5)


func set_view_mode(view_mode_index: int) -> void:
	match view_mode_index:
		0:  # 45 Degrees
			texture = _forty_five
		1:  # Isometric
			texture = _isometric
		2:  # Top Down
			texture = _top_down
		3:  # Front Side
			texture = _front_side
		4:  # Oblique Y
			texture = _oblique_y
		5:  # Oblique Z
			texture = _oblique_z
