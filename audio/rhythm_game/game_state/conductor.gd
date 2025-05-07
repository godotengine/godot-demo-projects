## Accurately tracks the current beat of a song.
class_name Conductor
extends Node

## If [code]true[/code], the song is paused. Setting [member is_paused] to
## [code]false[/code] resumes the song.
@export var is_paused: bool = false:
	get:
		if player:
			return player.stream_paused
		return false
	set(value):
		if player:
			player.stream_paused = value

@export_group("Nodes")
## The song player.
@export var player: AudioStreamPlayer

@export_group("Song Parameters")
## Beats per minute of the song.
@export var bpm: float = 100
## Offset (in milliseconds) of when the 1st beat of the song is in the audio
## file. [code]5000[/code] means the 1st beat happens 5 seconds into the track.
@export var first_beat_offset_ms: int = 0

@export_group("Filter Parameters")
## [code]cutoff[/code] for the 1€ filter. Decrease to reduce jitter.
@export var allowed_jitter: float = 0.1
## [code]beta[/code] for the 1€ filter. Increase to reduce lag.
@export var lag_reduction: float = 5

# Calling this is expensive, so cache the value. This should not change.
var _cached_output_latency: float = AudioServer.get_output_latency()

# General conductor state
var _is_playing: bool = false

# Audio thread state
var _song_time_audio: float = -100

# System time state
var _song_time_begin: float = 0
var _song_time_system: float = -100

# Filtered time state
var _filter: OneEuroFilter
var _filtered_audio_system_delta: float = 0


func _ready() -> void:
	# Ensure that playback state is always updating, otherwise the smoothing
	# filter causes issues.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if not _is_playing:
		return

	# Handle a web bug where AudioServer.get_time_since_last_mix() occasionally
	# returns unsigned 64-bit integer max value. This is likely due to minor
	# timing issues between the main/audio threads, thus causing an underflow
	# in the engine code.
	var last_mix := AudioServer.get_time_since_last_mix()
	if last_mix > 1000:
		last_mix = 0

	# First, calculate the song time using data from the audio thread. This
	# value is very jittery, but will always match what the player is hearing.
	_song_time_audio = (
		player.get_playback_position()
		# The 1st beat may not start at second 0 of the audio track. Compensate
		# with an offset setting.
		- first_beat_offset_ms / 1000.0
		# For most platforms, the playback position value updates in chunks,
		# with each chunk being one "mix". Smooth this out by adding in the time
		# since the last chunk was processed.
		+ last_mix
		# Current processed audio is heard later.
		- _cached_output_latency
	)

	# Next, calculate the song time using the system clock at render rate. This
	# value is very stable, but can drift from the playing audio due to pausing,
	# stuttering, etc.
	_song_time_system = (Time.get_ticks_usec() / 1000000.0) - _song_time_begin
	_song_time_system *= player.pitch_scale

	# We don't do anything else here. Check _physics_process next.


func _physics_process(delta: float) -> void:
	if not _is_playing:
		return

	# To have the best of both the audio-based time and system-based time, we
	# apply a smoothing filter (1€ filter) on the delta between the two values,
	# then add it to the system-based time. This allows us to have a stable
	# value that is also always accurate to what the player hears.
	#
	# Notes:
	# - The 1€ filter jitter reduction is more effective on values that don't
	#   change drastically between samples, so we filter on the delta (generally
	#   less variable between frames) rather than the time itself.
	# - We run the filter step in _physics_process to reduce the variability of
	#   different systems' update rates. The filter params are specifically
	#   tuned for 60 UPS.
	var audio_system_delta := _song_time_audio - _song_time_system
	_filtered_audio_system_delta = _filter.filter(audio_system_delta, delta)

	# Uncomment this to show the difference between raw and filtered time.
	#var song_time := _song_time_system + _filtered_audio_system_delta
	#print("Error: %+.1f ms" % [abs(song_time - _song_time_audio) * 1000.0])


func play() -> void:
	var filter_args := {
		"cutoff": allowed_jitter,
		"beta": lag_reduction,
	}
	_filter = OneEuroFilter.new(filter_args)

	player.play()
	_is_playing = true

	# Capture the start of the song using the system clock.
	_song_time_begin = (
		Time.get_ticks_usec() / 1000000.0
		# The 1st beat may not start at second 0 of the audio track. Compensate
		# with an offset setting.
		+ first_beat_offset_ms / 1000.0
		# Playback does not start immediately, but only when the next audio
		# chunk is processed (the "mix" step). Add in the time until that
		# happens.
		+ AudioServer.get_time_to_next_mix()
		# Add in additional output latency.
		+ _cached_output_latency
	)


func stop() -> void:
	player.stop()
	_is_playing = false


## Returns the current beat of the song.
func get_current_beat() -> float:
	var song_time := _song_time_system + _filtered_audio_system_delta
	return song_time / get_beat_duration()


## Returns the current beat of the song without smoothing.
func get_current_beat_raw() -> float:
	return _song_time_audio / get_beat_duration()


## Returns the duration of one beat (in seconds).
func get_beat_duration() -> float:
	return 60 / bpm
