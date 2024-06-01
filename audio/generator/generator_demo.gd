extends Node

# Keep the number of samples per second to mix low, as GDScript is not super fast.
var sample_hz := 22050.0
var pulse_hz := 440.0
var phase := 0.0

# Actual playback stream, assigned in _ready().
var playback: AudioStreamPlayback

func _fill_buffer() -> void:
	var increment := pulse_hz / sample_hz

	var to_fill: int = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1


func _process(_delta: float) -> void:
	_fill_buffer()


func _ready() -> void:
	# Setting mix rate is only possible before play().
	$Player.stream.mix_rate = sample_hz
	$Player.play()
	playback = $Player.get_stream_playback()
	# `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	_fill_buffer()


func _on_frequency_h_slider_value_changed(value: float) -> void:
	%FrequencyLabel.text = "%d Hz" % value
	pulse_hz = value


func _on_volume_h_slider_value_changed(value: float) -> void:
	# Use `linear_to_db()` to get a volume slider that matches perceptual human hearing.
	%VolumeLabel.text = "%.2f dB" % linear_to_db(value)
	$Player.volume_db = linear_to_db(value)
