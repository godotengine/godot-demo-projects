extends Control

# The path to the game scene
export (PackedScene) var game_scene;


func _ready():
	# warning-ignore:return_value_discarded
	get_node("StartButton").connect("pressed", self, "start_pressed")


func start_pressed():
	var seed_line_edit = get_node("SeedLineEdit")
	
	# If there is text in the LineEdit
	if seed_line_edit.text != "" or seed_line_edit.text != null:
		# Does it have any letters in it?
		var has_letters = false
		var numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
		for letter in seed_line_edit.text:
			if not letter in numbers:
				has_letters = true
				break

		# If the text has any letter is in, then we'll use the hash code, otherwise we'll use the inputted number
		if has_letters:
			seed(seed_line_edit.text.hash())
		else:
			seed(seed_line_edit.text.to_int())
	
	# If there is no text, then get a random seed using randomize()
	else:
		randomize()
	
	# Change the scene
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(game_scene);
