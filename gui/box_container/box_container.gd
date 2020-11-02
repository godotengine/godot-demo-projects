extends Control
# Description:
# This is a Demo show casing what you can do with BoxContainer Class.

# Explaining Stuff:
# The Box Container class have Three Nodes inherintes from it it,
# (VboxContainer, HboxContainer, ColorPicker) nodes,
# and using GDscript to make This Demo work.

# For more Information about these Three nodes,
# You can read about it in the Godot Doc,
# https://docs.godotengine.org/en/stable/classes/class_boxcontainer.html
# And/or you can watch videos Online explaining it.





# Code over here
signal color_rect_notified(node_id)


var junk_place_holder  # For removing annoying errors
var items_selected = []
var selecting_multiple = false
var is_mouse_on_background = false


func _ready():
	junk_place_holder = connect("color_rect_notified", self, "select_item")


func _input(event):
	if not event is InputEventMouseMotion:
		# Control key holding down functionality

		if event.is_action_pressed("ctrl"):
			selecting_multiple = true
		elif event.is_action_released("ctrl"):
			selecting_multiple = false

		# clears the items_selected array, if these three arguments are all true.
		elif is_mouse_on_background and event.is_action_pressed("ui_select") and not selecting_multiple:
			for i in range(items_selected.size()):
				items_selected[i].get_child(0).set_visible(false)
			items_selected.clear()


func select_item(color_rect):
	# Adds the color rect, but if it's already inside the array
	# It won't add it.

	if -1 == items_selected.find(color_rect):
		items_selected.append(color_rect)
		# Sets the child of last ColorRect visibility to true
		items_selected[items_selected.size() - 1].get_child(0).set_visible(true)

	# if ctrl key is not held down, it will remove everything
	# except the last rect you clicked.
	if items_selected.size() > 1 and not selecting_multiple:
		for i in range(items_selected.size() - 1):
			items_selected[0].get_child(0).set_visible(false)
			items_selected.remove(0)


# SIGNALS
func _on_BackGround_mouse_entered():
	is_mouse_on_background = true


func _on_BackGround_mouse_exited():
	is_mouse_on_background = false


func _on_ColorPickerBackGround_mouse_entered():
	is_mouse_on_background = false


func _on_ColorPicker_color_changed(new_color):
	for i in range(items_selected.size()):
		items_selected[i].color = new_color
