class_name Note
extends Node2D

@export_category("Nodes")
@export var conductor: Conductor

@export_category("Settings")
@export var x_offset: float = 0
@export var beat: float = 0

var _speed: float
var _movement_paused: bool = false
var _song_time_delta: float = 0


func _init() -> void:
	_speed = GlobalSettings.scroll_speed


func _ready() -> void:
	GlobalSettings.scroll_speed_changed.connect(_on_scroll_speed_changed)


func _process(_delta: float) -> void:
	if _movement_paused:
		return

	_update_position()


func update_beat(curr_beat: float) -> void:
	_song_time_delta = (curr_beat - beat) * conductor.get_beat_duration()

	_update_position()


func hit_perfect() -> void:
	_movement_paused = true

	modulate = Color.YELLOW

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.2)
	tween.parallel().tween_property($Sprite2D, "scale", 1.5 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


func hit_good() -> void:
	_movement_paused = true

	modulate = Color.DEEP_SKY_BLUE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.2)
	tween.parallel().tween_property($Sprite2D, "scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


func miss(stop_movement: bool = true) -> void:
	_movement_paused = stop_movement

	modulate = Color.DARK_RED

	var tween := create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)


func _update_position() -> void:
	if _song_time_delta > 0:
		# Slow the note down past the judgment line.
		position.y = _speed * _song_time_delta - _speed * pow(_song_time_delta, 2)
	else:
		position.y = _speed * _song_time_delta
	position.x = x_offset


func _on_scroll_speed_changed(speed: float) -> void:
	_speed = speed
