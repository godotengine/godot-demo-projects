extends Label

func _ready() -> void:
	text = "Godot Version: %s" % Engine.get_version_info().string
