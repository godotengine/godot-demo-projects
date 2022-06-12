extends Node

export(String, FILE, "*.json") var dialogue_file
var dialogue_keys = []
var dialogue_name = ""
var current = 0
var dialogue_text = ""

signal dialogue_started
signal dialogue_finished

func start_dialogue():
	emit_signal("dialogue_started")
	current = 0
	index_dialogue()
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


func next_dialogue():
	current += 1
	if current == dialogue_keys.size():
		emit_signal("dialogue_finished")
		return
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


func index_dialogue():
	var dialogue = load_dialogue(dialogue_file)
	dialogue_keys.clear()
	for key in dialogue:
		dialogue_keys.append(dialogue[key])


func load_dialogue(file_path):
	var file = File.new()
	if file.file_exists(file_path):
		file.open(file_path, file.READ)
		var dialogue = parse_json(file.get_as_text())
		return dialogue
