extends Button

func _ready():
	# This ensures that this Node won't be paused, allowing it to
	# process even when the SceneTree is paused. Without that it would
	# not be able to unpause the game. Note that you can set this through
	# the inspector as well.
	pause_mode = Node.PAUSE_MODE_PROCESS


func _toggled(button_pressed):
	# Pause or unpause the SceneTree based on whether the button is
	# toggled on or off.
	get_tree().paused = button_pressed
	if button_pressed:
		text = "Unpause"
	else:
		text = "Pause"
