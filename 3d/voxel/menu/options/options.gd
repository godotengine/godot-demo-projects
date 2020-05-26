extends HBoxContainer

var prev_menu


func _on_Back_pressed():
	prev_menu.visible = true
	visible = false
