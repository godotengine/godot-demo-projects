extends Node

signal dialogue_started
signal dialogue_finished

@export_file("*.json") var dialogue_file: String
var dialogue_keys := []
var dialogue_name := ""
var current := 0
var dialogue_text := ""


func start_dialogue() -> void:
	dialogue_started.emit()
	current = 0
	index_dialogue()
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


func next_dialogue() -> void:
	current += 1
	if current == dialogue_keys.size():
		dialogue_finished.emit()
		return
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


func index_dialogue() -> void:
	var dialogue: Dictionary = load_dialogue(dialogue_file)
	dialogue_keys.clear()
	for key: String in dialogue:
		dialogue_keys.append(dialogue[key])


func load_dialogue(file_path: String) -> Dictionary:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file:
		var test_json_conv := JSON.new()
		test_json_conv.parse(file.get_as_text())
		return test_json_conv.data

	return {}
