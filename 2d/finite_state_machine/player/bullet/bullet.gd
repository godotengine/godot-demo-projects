extends CharacterBody2D

var direction := Vector2()
@export var speed := 1000.0

@onready var root := get_tree().root

func _ready() -> void:
	set_as_top_level(true)


func _physics_process(delta: float) -> void:
	if not root.get_visible_rect().has_point(position):
		queue_free()

	var motion := direction * speed * delta
	var collision_info := move_and_collide(motion)
	if collision_info:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2(), $CollisionShape2D.shape.radius, Color.WHITE)
