extends Label

func _process(_delta: float) -> void:
	set_text("Godot Version: %s" % Engine.get_version_info().string)
