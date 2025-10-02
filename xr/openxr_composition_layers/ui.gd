extends Control

var button_count : int = 0


func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(16, 16)


func _on_button_pressed():
	button_count = button_count + 1
	$CountLabel.text = "The button has been pressed %d times!" % [ button_count ]
