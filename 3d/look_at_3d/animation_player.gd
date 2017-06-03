extends AnimationPlayer


func _on_play_button_toggled(is_pressed):
	if is_pressed:
		play("target_move")
	else:
		stop()
