extends Node

@onready var viewport: SubViewport = $SubViewport
@onready var viewport_initial_size: Vector2i = viewport.size
@onready var viewport_sprite: Sprite2D = $ViewportSprite


func _ready() -> void:
	get_viewport().size_changed.connect(_root_viewport_size_changed)


func _root_viewport_size_changed() -> void:
	viewport.size = Vector2.ONE * get_viewport().size.y
	viewport_sprite.scale = Vector2.ONE * viewport_initial_size.y / get_viewport().size.y
