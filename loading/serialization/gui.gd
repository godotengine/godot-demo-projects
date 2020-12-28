extends VBoxContainer


func _ready():
	var file = File.new()
	# Don't allow loading files that don't exist yet.
	$SaveLoad/LoadConfigFile.disabled = not file.file_exists(ProjectSettings.globalize_path("user://save_config_file.ini"))
	$SaveLoad/LoadJSON.disabled = not file.file_exists(ProjectSettings.globalize_path("user://save_json.json"))


func _on_open_user_data_folder_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open(ProjectSettings.globalize_path("user://"))
