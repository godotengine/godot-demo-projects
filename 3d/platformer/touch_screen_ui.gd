extends CanvasLayer

var player_script:= preload("res://player/player.gd")

func _ready() -> void:
	hide()
	if DisplayServer.is_touchscreen_available():
		show()

func _on_performance_toggled(toggled_on: bool) -> void:
	player_script.performance_mode = toggled_on
	for child in get_tree().get_nodes_in_group("bad_performer"):
		child.visible = !toggled_on
