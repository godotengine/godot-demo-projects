extends Control

var prev_menu: Control

func _on_Back_pressed() -> void:
	prev_menu.visible = true
	visible = false
