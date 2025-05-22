extends Node2D

const SONG_VOLUME_DB = -18

@export_category("Song Settings")
@export var bpm: float = 130
@export var song_length_beats: int = 32

@export_category("Nodes")
@export var max_fps_slider: HSlider
@export var max_fps_spinbox: SpinBox
@export var game_time_label: Label
@export var audio_time_label: Label

@onready var _master_bus_index: int = AudioServer.get_bus_index("Master")

var _tween: Tween
var _scheduled_song_start_time: float
var _scheduled_song_time: float


func _ready() -> void:
	_update_max_fps(10)

	# Both scheduled and non-scheduled players run simultaneously, but only one
	# set is playing audio at a time. By default, the scheduled players are muted.
	$SongScheduled.volume_linear = 0
	$MetronomeScheduled.volume_linear = 0

	# Scheduled players. Schedule for 1 second in the future.
	_scheduled_song_start_time = AudioServer.get_absolute_time() + 1
	print("Scheduled song starting at ", _scheduled_song_start_time)
	$SongScheduled.play_scheduled(_scheduled_song_start_time)
	$MetronomeScheduled.start(_scheduled_song_start_time)
	_scheduled_song_time = _scheduled_song_start_time

	# Non-scheduled players. Wait 1 second, then start playing.
	await get_tree().create_timer(1).timeout
	var sys_time := Time.get_ticks_usec() / 1000000.0
	$Song.play()
	$Metronome.start(sys_time)


func _process(_delta: float) -> void:
	var abs_time := AudioServer.get_absolute_time()
	var game_time := Time.get_ticks_usec() / 1000000.0

	# Show the new game/audio times.
	game_time_label.text = "Game Time: %.4f" % game_time
	audio_time_label.text = "Audio Time: %.4f" % abs_time

	var song_length := 60 / bpm * song_length_beats

	# If for some reason there isn't a song playing right now (e.g. game is in a
	# background tab on web), seek to the correct time and play the song.
	if abs_time > _scheduled_song_time + song_length:
		var prev_song_loop := floori((abs_time - _scheduled_song_start_time) / song_length)
		_scheduled_song_time = _scheduled_song_start_time + prev_song_loop * song_length
		$SongScheduled.play_scheduled(abs_time + 0.1, abs_time + 0.1 - _scheduled_song_time)

	# Schedule the next song loop manually.
	if abs_time > _scheduled_song_time:
		var next_song_loop := ceili((abs_time + 0.001 - _scheduled_song_start_time) / song_length)
		_scheduled_song_time = _scheduled_song_start_time + next_song_loop * song_length
		$SongScheduled.play_scheduled(_scheduled_song_time)


func _update_max_fps(max_fps: int) -> void:
	Engine.max_fps = max_fps
	ProjectSettings.set("application/run/max_fps", max_fps)
	max_fps_slider.value = max_fps
	max_fps_spinbox.value = max_fps


func _on_max_fps_h_slider_value_changed(value: float) -> void:
	_update_max_fps(int(value))


func _on_max_fps_spin_box_value_changed(value: float) -> void:
	_update_max_fps(int(value))


func _on_use_play_scheduled_check_button_toggled(toggled_on: bool) -> void:
	if _tween:
		_tween.kill()

	if toggled_on:
		_tween = create_tween().parallel()
		_tween.tween_property($Song, "volume_linear", 0, 0.2)
		_tween.tween_property($Metronome, "volume_linear", 0, 0.2)
		_tween.tween_property($SongScheduled, "volume_linear", db_to_linear(SONG_VOLUME_DB), 0.2)
		_tween.tween_property($MetronomeScheduled, "volume_linear", 1, 0.2)
	else:
		_tween = create_tween().parallel()
		_tween.tween_property($SongScheduled, "volume_linear", 0, 0.2)
		_tween.tween_property($MetronomeScheduled, "volume_linear", 0, 0.2)
		_tween.tween_property($Song, "volume_linear", db_to_linear(SONG_VOLUME_DB), 0.2)
		_tween.tween_property($Metronome, "volume_linear", 1, 0.2)


func _on_volume_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus_index, value)
