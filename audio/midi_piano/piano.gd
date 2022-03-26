extends Control

# A standard piano with 88 keys has keys from 21 to 108.
# To get a different set of keys, modify these numbers.
# A maximally extended 108-key piano goes from 12 to 119.
# A 76-key piano goes from 23 to 98, 61-key from 36 to 96,
# 49-key from 36 to 84, 37-key from 41 to 77, and 25-key
# from 48 to 72. Middle C is pitch number 60, A440 is 69.
const START_KEY = 21
const END_KEY = 108

const WhiteKeyScene = preload("res://piano_keys/white_piano_key.tscn")
const BlackKeyScene = preload("res://piano_keys/black_piano_key.tscn")

var piano_key_dict := Dictionary()

onready var white_keys = $WhiteKeys
onready var black_keys = $BlackKeys

func _ready():
	# Sanity checks.
	if _is_note_index_sharp(_pitch_index_to_note_index(START_KEY)):
		printerr("The start key can't be a sharp note (limitation of this piano-generating algorithm). Try 21.")
		return

	for i in range(START_KEY, END_KEY + 1):
		piano_key_dict[i] = _create_piano_key(i)

	if white_keys.get_child_count() != black_keys.get_child_count():
		_add_placeholder_key(black_keys)
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())


func _input(input_event):
	if not (input_event is InputEventMIDI):
		return
	var midi_event: InputEventMIDI = input_event
	if midi_event.pitch < START_KEY or midi_event.pitch > END_KEY:
		# The given pitch isn't on the on-screen keyboard, so return.
		return
	_print_midi_info(midi_event)
	var key: PianoKey = piano_key_dict[midi_event.pitch]
	if midi_event.message == MIDI_MESSAGE_NOTE_ON:
		key.activate()
	else:
		key.deactivate()


func _add_placeholder_key(container):
	var placeholder = Control.new()
	placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder.name = "Placeholder"
	container.add_child(placeholder)


func _create_piano_key(pitch_index):
	var note_index = _pitch_index_to_note_index(pitch_index)
	var piano_key: PianoKey
	if _is_note_index_sharp(note_index):
		piano_key = BlackKeyScene.instance()
		black_keys.add_child(piano_key)
	else:
		piano_key = WhiteKeyScene.instance()
		white_keys.add_child(piano_key)
		if _is_note_index_lacking_sharp(note_index):
			_add_placeholder_key(black_keys)
	piano_key.setup(pitch_index)
	return piano_key


func _is_note_index_lacking_sharp(note_index: int):
	# B and E, because no B# or E#
	return note_index in [2, 7]


func _is_note_index_sharp(note_index: int):
	# A#, C#, D#, F#, and G#
	return note_index in [1, 4, 6, 9, 11]


func _pitch_index_to_note_index(pitch: int):
	pitch += 3
	return pitch % 12


func _print_midi_info(midi_event: InputEventMIDI):
	print(midi_event)
	print("Channel: " + str(midi_event.channel))
	print("Message: " + str(midi_event.message))
	print("Pitch: " + str(midi_event.pitch))
	print("Velocity: " + str(midi_event.velocity))
	print("Instrument: " + str(midi_event.instrument))
	print("Pressure: " + str(midi_event.pressure))
	print("Controller number: " + str(midi_event.controller_number))
	print("Controller value: " + str(midi_event.controller_value))
