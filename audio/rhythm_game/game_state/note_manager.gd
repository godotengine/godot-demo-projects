class_name NoteManager
extends Node2D

signal play_stats_updated(play_stats: PlayStats)
signal note_hit(beat: float, hit_type: Enums.HitType, hit_error: float)
signal song_finished(play_stats: PlayStats)

const NOTE_SCENE = preload("res://objects/note/note.tscn")
const HIT_MARGIN_PERFECT = 0.050
const HIT_MARGIN_GOOD = 0.150
const HIT_MARGIN_MISS = 0.300

@export var conductor: Conductor
@export var time_type: Enums.TimeType = Enums.TimeType.FILTERED
@export var chart: ChartData.Chart = ChartData.Chart.THE_COMEBACK

var _notes: Array[Note] = []

var _play_stats: PlayStats
var _hit_error_acc: float = 0.0
var _hit_count: int = 0


func _ready() -> void:
	_play_stats = PlayStats.new()
	_play_stats.changed.connect(
		func() -> void:
			play_stats_updated.emit(_play_stats)
	)

	var chart_data := ChartData.get_chart_data(chart)

	var note_beats: Array[float] = []
	for measure_i in range(chart_data.size()):
		var measure: Array = chart_data[measure_i]
		var subdivision := 1.0 / measure.size() * 4
		for note_i: int in range(measure.size()):
			var beat := measure_i * 4 + note_i * subdivision
			if measure[note_i] == 1:
				note_beats.append(beat)

	for beat in note_beats:
		var note := NOTE_SCENE.instantiate() as Note
		note.beat = beat
		note.conductor = conductor
		note.update_beat(-100)
		add_child(note)
		_notes.append(note)


func _process(_delta: float) -> void:
	if _notes.is_empty():
		return

	var curr_beat := _get_curr_beat()
	for i in range(_notes.size()):
		_notes[i].update_beat(curr_beat)

	_miss_old_notes()

	if Input.is_action_just_pressed("main_key"):
		_handle_keypress()

	if _notes.is_empty():
		_finish_song()


func _miss_old_notes() -> void:
	while not _notes.is_empty():
		var note := _notes[0] as Note
		var note_delta := _get_note_delta(note)

		if note_delta > HIT_MARGIN_GOOD:
			# Time is past the note's hit window, miss.
			note.miss(false)
			_notes.remove_at(0)
			_play_stats.miss_count += 1
			note_hit.emit(note.beat, Enums.HitType.MISS_LATE, note_delta)
		else:
			# Note is still hittable, so stop checking rest of the (later)
			# notes.
			break


func _handle_keypress() -> void:
	var note := _notes[0] as Note
	var hit_delta := _get_note_delta(note)
	if hit_delta < -HIT_MARGIN_MISS:
		# Note is not hittable, do nothing.
		pass
	elif -HIT_MARGIN_PERFECT <= hit_delta and hit_delta <= HIT_MARGIN_PERFECT:
		# Hit on time, perfect.
		note.hit_perfect()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.perfect_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		note_hit.emit(note.beat, Enums.HitType.PERFECT, hit_delta)
	elif -HIT_MARGIN_GOOD <= hit_delta and hit_delta <= HIT_MARGIN_GOOD:
		# Hit slightly off time, good.
		note.hit_good()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.good_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		if hit_delta < 0:
			note_hit.emit(note.beat, Enums.HitType.GOOD_EARLY, hit_delta)
		else:
			note_hit.emit(note.beat, Enums.HitType.GOOD_LATE, hit_delta)
	elif -HIT_MARGIN_MISS <= hit_delta and hit_delta <= HIT_MARGIN_MISS:
		# Hit way off time, miss.
		note.miss()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.miss_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		if hit_delta < 0:
			note_hit.emit(note.beat, Enums.HitType.MISS_EARLY, hit_delta)
		else:
			note_hit.emit(note.beat, Enums.HitType.MISS_LATE, hit_delta)


func _finish_song() -> void:
	song_finished.emit(_play_stats)


func _get_note_delta(note: Note) -> float:
	var curr_beat := _get_curr_beat()
	var beat_delta := curr_beat - note.beat
	return beat_delta * conductor.get_beat_duration()


func _get_curr_beat() -> float:
	var curr_beat: float
	match time_type:
		Enums.TimeType.FILTERED:
			curr_beat = conductor.get_current_beat()
		Enums.TimeType.RAW:
			curr_beat = conductor.get_current_beat_raw()
		_:
			assert(false, "Unknown TimeType: %s" % time_type)
			curr_beat = conductor.get_current_beat()

	# Adjust the timing for input delay. While this will shift the note
	# positions such that "on time" does not line up visually with the guide
	# sprite, the resulting visual is a lot smoother compared to readjusting the
	# note position after hitting it.
	curr_beat -= GlobalSettings.input_latency_ms / 1000.0 / conductor.get_beat_duration()

	return curr_beat
