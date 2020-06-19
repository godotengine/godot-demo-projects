extends Label


func _process(_delta):
	set_text("Godot Version: %s" % Engine.get_version_info().string)
