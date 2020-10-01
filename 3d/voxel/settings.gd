extends Node

var render_distance = 7
var fog_enabled = true

var world_type = 0 # Not saved, only used during runtime.

var _save_path = "user://settings.json"
var _loaded = false


func _enter_tree():
	if Settings._loaded:
		printerr("Error: Settings is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Settings._loaded = true

	var file = File.new()
	if file.file_exists(_save_path):
		file.open(_save_path, File.READ)
		while file.get_position() < file.get_len():
			# Get the saved dictionary from the next line in the save file
			var data = parse_json(file.get_line())
			render_distance = data["render_distance"]
			fog_enabled = data["fog_enabled"]
		file.close()
	else:
		save_settings()


func save_settings():
	var file = File.new()
	file.open(_save_path, File.WRITE)
	var data = {
		"render_distance": render_distance,
		"fog_enabled": fog_enabled,
	}
	file.store_line(to_json(data))
	file.close()
