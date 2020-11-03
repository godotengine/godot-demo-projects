extends Control

# NOTE FROM DEV: This Demo Show cases how to make the game pause,
# And show you a way on making the pause menu, But also a Polished one.
# In this Script, There is a function called animations(),
# Try playing around with the different animations i've made :)
# To see the Different effects you can do With the Tween Node.

export(String) var showing_animation = "fade_in"
export(String) var hidding_animation = "slide_out"

export(float) var showing_length = 0.2
export(float) var hidding_length = 0.2
export(Color, RGBA) var hue_shift_from = Color(1, 1, 1, 0)
export(Color, RGBA) var hue_shift_to = Color(0, 0, 0, 1)

# Node References
onready var resume_button = $CenterContainer/BackGround/VBoxContainer/Resume
onready var quit_button = $CenterContainer/BackGround/VBoxContainer/Quit
onready var click_me_button = $CenterContainer/BackGround/VBoxContainer/ClickMe
onready var tween_node = $CenterContainer/Tween
onready var info_label = get_parent().get_node("Info")


func _ready():
	# Connecting Signals throught code, you can do the same Inside the Editor
	# through, *Select A Node* --> Node tab --> Signals Menu.
	resume_button.connect("pressed", self, "_Resume_button_pressed")
	quit_button.connect("pressed", self, "_Quit_button_pressed")
	click_me_button.connect("pressed", self, "show_add_text")

	# Sets the pause mode to Process *and all of it's children as well*,
	# It'll NOT stop processing, even if the Scene Tree is Paused or not.
	set_pause_mode(2)


func _input(event):
	if not event is InputEventMouseMotion:
		if event.is_action_pressed("ui_cancel"):
			set_visibility()


func set_visibility():
	if self.is_visible():
		info_label.show()
		animations(hidding_animation)
		free_click_me_labels()
		get_tree().paused = false
	else:
		info_label.hide()
		animations(showing_animation)
		get_tree().paused = true



# Animations Templates
func animations(animation):
	match animation:
		"slide_in":
			show()
			tween_node.interpolate_property(self, "rect_position", 
					Vector2(0, get_viewport().size.y), Vector2.ZERO, showing_length, Tween.TRANS_QUART, Tween.EASE_OUT)
			tween_node.start()
			resume_button.grab_focus() # the resume button will be focused
		"slide_out":
			tween_node.interpolate_property(self, "rect_position", 
					Vector2.ZERO, Vector2(0, get_viewport().size.y), hidding_length, Tween.TRANS_QUART, Tween.EASE_IN)
			tween_node.start()
			yield(get_tree().create_timer(hidding_length), "timeout")
			hide()
			set_position(Vector2.ZERO) # Rect Position Resetter
		"fade_in":
			tween_node.interpolate_property(self, "modulate:a", 
					0.0, 1.0, showing_length, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween_node.start()
			show()
			resume_button.grab_focus()
		"fade_out":
			tween_node.interpolate_property(self, "modulate:a", 
					1.0, 0.0, hidding_length, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween_node.start()
			yield(get_tree().create_timer(hidding_length), "timeout")
			hide()
		"hue_shift_show":
			show()
			tween_node.interpolate_property(self, "modulate", 
					hue_shift_from, hue_shift_to, showing_length + 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
			tween_node.start()
			resume_button.grab_focus()
		"hue_shift_hide":
			tween_node.interpolate_property(self, "modulate", 
					hue_shift_to, hue_shift_from, showing_length + 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
			tween_node.start()
			yield(get_tree().create_timer(hidding_length + 0.1), "timeout")
			hide()
		_:
			# The _ character in match is usful for debugging.
			print("Error, the animation name does not exist")


# frees all nodes, except PauseMenu,
# freeing something using queue_free() or 'Node.free()',
# is Basically Deleting it from Memory (RAM) NOT from your Project Files (on your Storage Media).
func free_click_me_labels():
	for i in range(1, get_child_count()):
		get_child(i).queue_free()


# SIGNALS
func _Resume_button_pressed():
	set_visibility()
	free_click_me_labels()


func _Quit_button_pressed():
	get_tree().quit()


func show_add_text():
	var label = Label.new()
	label.text = "You've clicked me!"
	# Choses a Random float value, between 0 and the Screen's width and height *with a 100/-100 offset values*.
	label._set_position(Vector2(rand_range(100, get_viewport().size.x - 100), 
			rand_range(100, get_viewport().size.y - 100)))
	label.set_rotation_degrees(rand_range(-45, 45))
	
	# OverWrites the current Theme Font.
	label.add_font_override("font", load("res://RES/text_font_style.tres"))
	add_child(label)
