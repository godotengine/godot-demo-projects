extends Node

@export var sub_viewport_initial_size: Vector2
@export var main_viewport_initial_size: Vector2
@onready var sub_viewport: SubViewport = $MySubViewport
@onready var viewport_sprite: Sprite2D = $ViewportSprite


func _ready() -> void:
	get_viewport().size_changed.connect(_root_viewport_size_changed)
	_root_viewport_size_changed()


func _root_viewport_size_changed() -> void:
	# Automatically change sub_viewport resolution according to the window size.
	# This ensures the sub_viewport remains crisp at window sizes higher than the default.
	sub_viewport.size.x = sub_viewport_initial_size.x * (get_viewport().size.y / main_viewport_initial_size.y)
	sub_viewport.size.y = sub_viewport_initial_size.y * (get_viewport().size.y / main_viewport_initial_size.y)
	viewport_sprite.scale.x = sub_viewport_initial_size.x / sub_viewport.size.x
	viewport_sprite.scale.y = sub_viewport_initial_size.y / sub_viewport.size.y
