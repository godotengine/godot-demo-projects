extends Button

const TITLE_SCREEN_PATH = "res://TitleScreen.tscn"

func _ready():
	# Assure the mouse is visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	  
	# Connect the pressed signal to the chance_scene_to_title function
	# warning-ignore:return_value_discarded
	connect("pressed", self, "change_scene_to_title")


func change_scene_to_title():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(TITLE_SCREEN_PATH)
