extends Node2D

const SONG_VOLUME_DB = -18

@export_category("Song Settings")
@export var bpm: float = 130
@export var song_beat_count: int = 32

@export_category("Nodes")
@export var use_play_scheduled_toggle: CheckButton
@export var max_fps_slider: HSlider
@export var max_fps_spinbox: SpinBox
@export var beat_count_slider: HSlider
@export var beat_count_spinbox: SpinBox
@export var game_time_label: Label
@export var audio_time_label: Label
@export var loop_settings_container: VBoxContainer
@export var stop_curr_loop_button: Button
@export var cancel_next_loop_button: Button

@onready var _master_bus_index: int = AudioServer.get_bus_index("Master")

var _tween: Tween
var _scheduled_song_start_time: float
var _scheduled_song_time: float
var _curr_playback: AudioStreamPlaybackScheduled
var _next_playback: AudioStreamPlaybackScheduled
var _prev_scheduled_beat_count: int = song_beat_count


func _ready() -> void:
	_update_max_fps(10)
	_update_song_beat_count(32)

	# Both scheduled and non-scheduled players run simultaneously, but only one
	# set is playing audio at a time. By default, the scheduled players are muted.
	$Song.volume_linear = 0
	$Metronome.volume_linear = 0
	$SongScheduled.volume_linear = 0
	$MetronomeScheduled.volume_linear = 0
	_on_use_play_scheduled_check_button_toggled(use_play_scheduled_toggle.button_pressed)

	# Scheduled players. Schedule for 1 second in the future.
	_scheduled_song_start_time = AudioServer.get_absolute_time() + 1
	print("Scheduled song starting at ", _scheduled_song_start_time)
	_next_playback = $SongScheduled.play_scheduled(_scheduled_song_start_time)
	_next_playback.scheduled_end_time = _scheduled_song_start_time + (60 / bpm * song_beat_count)
	_prev_scheduled_beat_count = song_beat_count
	$MetronomeScheduled.start(_scheduled_song_start_time)
	_scheduled_song_time = _scheduled_song_start_time

	# Non-scheduled players. Wait 1 second, then start playing.
	await get_tree().create_timer(1).timeout
	var sys_time: float = Time.get_ticks_usec() / 1000000.0
	$Song.play()
	$Metronome.start(sys_time)


func _process(_delta: float) -> void:
	var abs_time: float = AudioServer.get_absolute_time()
	var game_time: float = Time.get_ticks_usec() / 1000000.0

	# Show the new game/audio times.
	game_time_label.text = "Game Time: %.4f" % game_time
	audio_time_label.text = "Audio Time: %.4f" % abs_time

	var beat_time: float = 60.0 / bpm
	var song_length: float = beat_time * _prev_scheduled_beat_count

	# If for some reason there isn't a song playing right now (e.g. game is in a
	# background tab on web), seek to the correct time and play the song.
	if abs_time > _scheduled_song_time + song_length:
		var missed_loops: int = floori((abs_time - _scheduled_song_time) / song_length)
		_scheduled_song_time += missed_loops * song_length
		var playback: AudioStreamPlaybackScheduled
		playback = $SongScheduled.play_scheduled(abs_time + 0.1, abs_time + 0.1 - _scheduled_song_time)
		playback.scheduled_end_time = _scheduled_song_time + song_length
		_prev_scheduled_beat_count = song_beat_count
		song_length = beat_time * _prev_scheduled_beat_count

	# Schedule the next song loop manually.
	if abs_time > _scheduled_song_time:
		_curr_playback = _next_playback
		_scheduled_song_time += song_length
		_next_playback = $SongScheduled.play_scheduled(_scheduled_song_time)
		_next_playback.scheduled_end_time = _scheduled_song_time + (beat_time * song_beat_count)
		_prev_scheduled_beat_count = song_beat_count
		if use_play_scheduled_toggle.button_pressed:
			stop_curr_loop_button.disabled = not _curr_playback.is_playing()
			cancel_next_loop_button.disabled = not _next_playback.is_scheduled()


func _update_max_fps(max_fps: int) -> void:
	Engine.max_fps = max_fps
	ProjectSettings.set("application/run/max_fps", max_fps)
	max_fps_slider.value = max_fps
	max_fps_spinbox.value = max_fps


func _update_song_beat_count(beat_count: int) -> void:
	song_beat_count = beat_count
	beat_count_slider.value = beat_count
	beat_count_spinbox.value = beat_count

	# Update the next playback's length with the new song beat count.
	if _next_playback:
		_next_playback.scheduled_end_time = _scheduled_song_time + (60 / bpm * song_beat_count)
		_prev_scheduled_beat_count = song_beat_count


func _on_max_fps_h_slider_value_changed(value: float) -> void:
	_update_max_fps(int(value))


func _on_max_fps_spin_box_value_changed(value: float) -> void:
	_update_max_fps(int(value))


func _on_song_beat_count_h_slider_value_changed(value: float) -> void:
	_update_song_beat_count(int(value))


func _on_song_beat_count_spin_box_value_changed(value: float) -> void:
	_update_song_beat_count(int(value))


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

	loop_settings_container.visible = toggled_on
	beat_count_slider.editable = toggled_on
	beat_count_spinbox.editable = toggled_on
	if toggled_on:
		if _curr_playback:
			stop_curr_loop_button.disabled = not _curr_playback.is_playing()
		if _next_playback:
			cancel_next_loop_button.disabled = not _next_playback.is_scheduled()
	else:
		stop_curr_loop_button.disabled = true
		cancel_next_loop_button.disabled = true


func _on_volume_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus_index, value)


func _on_stop_curr_button_pressed() -> void:
	if _curr_playback:
		_curr_playback.stop()
	stop_curr_loop_button.release_focus()
	stop_curr_loop_button.disabled = true


func _on_cancel_next_button_pressed() -> void:
	if _next_playback:
		_next_playback.cancel()
	cancel_next_loop_button.release_focus()
	cancel_next_loop_button.disabled = true
