# Spawn RigidBody rain 500px apart to enable
# side by side comparisons.
extends Node2D

@export var mass: float = 0.27
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 12345


func spawn_circle_body() -> void:
	var rb := RigidBody2D.new()
	var rb2 := RigidBody2D.new()
	var cs := CollisionShape2D.new()
	var cs2 := CollisionShape2D.new()
	var sp := CircleShape2D.new()
	var vn := VisibleOnScreenNotifier2D.new()
	var vn2 := VisibleOnScreenNotifier2D.new()
	sp.radius = 10.0 * rng.randf_range(0.5, 3.5)
	cs.shape = sp
	cs2.shape = sp

	var x := rng.randf_range(-200.0, 200.0)
	rb.mass = mass * (sp.radius / 20.0) ** 3
	rb.transform.origin.x = x
	rb.add_child(cs)
	rb.add_child(vn)
	add_child(rb)

	rb2.mass = mass * (sp.radius / 20.0) ** 3
	rb2.transform.origin.x = x + 500.0
	rb2.add_child(cs2)
	rb2.add_child(vn2)
	add_child(rb2)

	vn.screen_exited.connect(_on_screen_exited.bind(rb))
	vn2.screen_exited.connect(_on_screen_exited.bind(rb2))


func _on_screen_exited(rb: RigidBody2D) -> void:
	rb.queue_free()


func _on_spawn_timer_timeout() -> void:
	spawn_circle_body()
