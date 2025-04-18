extends CheckButton


func _on_check_button_toggled(toggled_on: bool) -> void:
	get_tree().physics_interpolation = toggled_on
