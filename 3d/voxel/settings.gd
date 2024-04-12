extends Node

var render_distance = 7
var fog_enabled = true

var fog_distance = 32.0 # Not saved, only used during runtime.
var world_type = 0 # Not saved, only used during runtime.

var _save_path = "user://settings.json"
@warning_ignore("unused_private_class_variable")
var _loaded = false


func _enter_tree():
	if Settings._loaded:
		printerr("Error: Settings is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + String(get_path()))
	else:
		Settings._loaded = true

	if FileAccess.file_exists(_save_path):
		var file = FileAccess.open(_save_path, FileAccess.READ)
		while file.get_position() < file.get_length():
			# Get the saved dictionary from the next line in the save file
			var json = JSON.new()
			json.parse(file.get_line())
			var data = json.get_data()
			render_distance = data["render_distance"]
			fog_enabled = data["fog_enabled"]
	else:
		save_settings()


func save_settings():
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	var data = {
		"render_distance": render_distance,
		"fog_enabled": fog_enabled,
	}
	file.store_line(JSON.stringify(data))
