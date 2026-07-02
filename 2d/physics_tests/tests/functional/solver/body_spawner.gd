# Spawn random RigidBody scenes.
extends Node2D

@export var body_scenes: Array[PackedScene]
@export var body_spawn_roll: Array[int]
@export var mass: float = 0.27

var _rng := RandomNumberGenerator.new()
var _total_roll: int = 0
var _accum_roll: Array[int]


func _sum(accum: int, number: int) -> int:
	return accum + number


func _ready() -> void:
	_rng.seed = 12345
	for i in body_spawn_roll.size():
		_total_roll += body_spawn_roll[i]
		_accum_roll.append(_total_roll)


func spawn_body() -> void:
	var rndi := _rng.randi_range(0, _total_roll)
	var pick: int = 0
	for i in body_spawn_roll.size():
		if rndi <= _accum_roll[i]:
			pick = i
			break

	var vn := VisibleOnScreenNotifier2D.new()
	var rb: RigidBody2D = body_scenes[pick].instantiate()
	rb.transform.origin.x = _rng.randf_range(-200.0, 200.0)

	rb.add_child(vn)
	add_child(rb)
	vn.screen_exited.connect(_on_screen_exited.bind(rb))


func _on_screen_exited(rb: RigidBody2D) -> void:
	rb.queue_free()


func _on_spawn_timer_timeout() -> void:
	spawn_body()
