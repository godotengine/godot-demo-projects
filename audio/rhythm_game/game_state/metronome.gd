extends AudioStreamPlayer

@export var conductor: Conductor

var _playing: bool = false
var _last_beat: float = -17  # 16 beat count-in
var _cached_latency: float = AudioServer.get_output_latency()


func _process(_delta: float) -> void:
	if not _playing:
		return

	# Note that this implementation is flawed since every tick is rounded to the
	# next mix window (~11ms at the default 44100 Hz mix rate) due to Godot's
	# audio mix buffer. Precise audio scheduling is requested in
	# https://github.com/godotengine/godot-proposals/issues/1151.
	var curr_beat := conductor.get_current_beat() + _cached_latency
	if GlobalSettings.enable_metronome and floor(curr_beat) > floor(_last_beat):
		play()
	_last_beat = max(_last_beat, curr_beat)


func start() -> void:
	_playing = true
