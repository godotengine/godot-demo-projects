extends ScheduledAudioStreamPlayer

@export var bpm: float = 130

var _running: bool = false
var _start_absolute_time: float = 0
var _scheduled_time: float = -1


func _process(_delta: float) -> void:
	if not _running:
		return

	# Once the currently scheduled tick has started, begin scheduling the next
	# one.
	var curr_time: float = AudioServer.get_absolute_time()
	if curr_time > _scheduled_time:
		var beat_time: float = 60.0 / bpm
		var next_tick: int = ceili((curr_time - _start_absolute_time) / beat_time)
		_scheduled_time = _start_absolute_time + next_tick * beat_time
		play_scheduled(_scheduled_time)
		print("scheduling tick: ", _scheduled_time, " ", next_tick)


func start(start_absolute_time: float) -> void:
	_running = true
	_start_absolute_time = start_absolute_time
	_scheduled_time = start_absolute_time - 60 / bpm
