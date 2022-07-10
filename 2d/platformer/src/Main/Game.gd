extends Node
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.


# The "_" prefix is a convention to indicate that variables are private,
# that is to say, another node or script should not access them.
onready var _pause_menu = $InterfaceLayer/PauseMenu


func _init():
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()


func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		# We need to clean up a little bit first to avoid Viewport errors.
		if name == "Splitscreen":
			$Black/SplitContainer/ViewportContainer1.free()
			$Black.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
	# The desired behavior is when pausing is to pause the gamplay,
	# but the Pause Menu should continue to process.
	# To achieve this, the "Pause Mode" field is used on nodes in the Game scene:
	# 1. The root node in the Game scene is set to process even when the game is paused
	#   (via Pause Mode = Process), so this Game script keeps running in order to open/close
	#   the Pause Menu when the player presses the "toggle_pause" action.
	# 2. The Level scene has Pause Mode = Stop (and its child Player scene has Pause Mode = Inherit),
	#   so the gameplay will stop.
	# 3. The InterfaceLayer node has Pause Mode = Inherit, with its child PauseMenu scene having
	#   Pause Mode = Process, so it will continue to process even when the game is paused.
	# To see the Pause Mode of any node, select the node and you'll see "Pause Mode" near the bottom
	# of the Inspector under "Node" fields.
	elif event.is_action_pressed("toggle_pause"):
		var tree = get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().set_input_as_handled()

	elif event.is_action_pressed("splitscreen"):
		if name == "Splitscreen":
			# We need to clean up a little bit first to avoid Viewport errors.
			$Black/SplitContainer/ViewportContainer1.free()
			$Black.queue_free()
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://src/Main/Game.tscn")
		else:
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://src/Main/Splitscreen.tscn")
