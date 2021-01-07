extends Control

const trans_list = ["Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back"]
const eases_list = ["In", "Out", "InOut", "OutIn"]
const modes_list = ["Move", "Color", "Scale", "Rotate", "Callback", "Follow", "Repeat", "Pause"]

var current_trans = Tween.TRANS_LINEAR
var current_ease = Tween.EASE_IN

onready var tween = $Tween
onready var trans_vbox = $Controls/Transitions
onready var eases_vbox = $Controls/Eases
onready var modes_vbox = $Controls/Modes
onready var timeline = $Top/Timeline
onready var color_from_picker = $Controls/ColorFrom/ColorPicker
onready var color_to_picker = $Controls/ColorTo/ColorPicker
onready var area_label = $Top/Area/RichTextLabel
onready var sprite = $Top/Area/Sprite
onready var follow = $Top/Area/Follow
onready var follow_2 = $Top/Area/Follow2
onready var size = $Top/Area.get_size()

onready var move_mode = modes_vbox.get_node(@"Move")
onready var color_mode = modes_vbox.get_node(@"Color")
onready var scale_mode = modes_vbox.get_node(@"Scale")
onready var rotate_mode = modes_vbox.get_node(@"Rotate")
onready var callback_mode = modes_vbox.get_node(@"Callback")
onready var follow_mode = modes_vbox.get_node(@"Follow")
onready var repeat_mode = modes_vbox.get_node(@"Repeat")
onready var paused_mode = modes_vbox.get_node(@"Pause")

func _ready():
	for index in range(trans_list.size()):
		trans_vbox.get_node(trans_list[index]).connect("pressed", self, "on_trans_changed", [index])

	for index in range(eases_list.size()):
		eases_vbox.get_node(eases_list[index]).connect("pressed", self, "on_eases_changed", [index])

	for index in range(modes_list.size()):
		modes_vbox.get_node(modes_list[index]).connect("pressed", self, "on_modes_changed", [index])

	color_from_picker.set_pick_color(Color.red)
	color_to_picker.set_pick_color(Color.cyan)

	for node in [trans_vbox, eases_vbox, modes_vbox]:
		node.get_child(1).set_pressed(true)
	modes_vbox.get_node(@"Repeat").set_pressed(true)

	reset_tween()


func on_trans_changed(index):
	for i in range(trans_list.size()):
		var btn = trans_vbox.get_node(trans_list[i])
		btn.set_pressed(i == index)

	current_trans = index
	reset_tween()


func on_eases_changed(index):
	for i in range(eases_list.size()):
		var btn = eases_vbox.get_node(eases_list[i])
		btn.set_pressed(i == index)

	current_ease = index
	reset_tween()


func on_modes_changed(index):
	if modes_list[index] == "Pause":
		if paused_mode.is_pressed():
			tween.stop_all()
		else:
			tween.resume_all()
	else:
		reset_tween()


func _on_ColorPicker_color_changed(_color):
	reset_tween()


func reset_tween():
	var pos = tween.tell()
	tween.reset_all()
	tween.remove_all()

	if move_mode.is_pressed():
		# The first line moves from the top left to the bottom right, while
		# the second line moves backwards afterwards (there is a delay of 2).
		# These are different (_method vs _property) only for the sake of
		# showcasing interpolation of both methods and properties.
		# The syntax is (object, method/property name, from value, to value,
		# duration, transition type, ease type, delay), last 3 optional.
		tween.interpolate_method(sprite, "set_position", Vector2.ZERO, size, 2, current_trans, current_ease)
		tween.interpolate_property(sprite, "position", size, Vector2.ZERO, 2, current_trans, current_ease, 2)

	if color_mode.is_pressed():
		tween.interpolate_method(sprite, "set_modulate", color_from_picker.get_pick_color(), color_to_picker.get_pick_color(), 2, current_trans, current_ease)
		tween.interpolate_property(sprite, "modulate", color_to_picker.get_pick_color(), color_from_picker.get_pick_color(), 2, current_trans, current_ease, 2)
	else:
		sprite.set_modulate(Color.white)

	if scale_mode.is_pressed():
		tween.interpolate_method(sprite, "set_scale", Vector2(0.5, 0.5), Vector2(1.5, 1.5), 2, current_trans, current_ease)
		tween.interpolate_property(sprite, "scale", Vector2(1.5, 1.5), Vector2(0.5, 0.5), 2, current_trans, current_ease, 2)
	else:
		sprite.set_scale(Vector2.ONE)

	if rotate_mode.is_pressed():
		tween.interpolate_method(sprite, "set_rotation_degrees", 0, 360, 2, current_trans, current_ease)
		tween.interpolate_property(sprite, "rotation_degrees", 360, 0, 2, current_trans, current_ease, 2)

	if callback_mode.is_pressed():
		tween.interpolate_callback(self, 0.5, "on_callback", "0.5 seconds after")
		tween.interpolate_callback(self, 0.2, "on_callback", "1.2 seconds after")

	if follow_mode.is_pressed():
		follow.show()
		follow_2.show()

		tween.follow_method(follow, "set_position", Vector2(0, size.y), sprite, "get_position", 2, current_trans, current_ease)
		tween.targeting_method(follow, "set_position", sprite, "get_position", Vector2(0, size.y), 2, current_trans, current_ease, 2)

		tween.targeting_property(follow_2, "position", sprite, "position", Vector2(size.x, 0), 2, current_trans, current_ease)
		tween.follow_property(follow_2, "position", Vector2(size.x, 0), sprite, "position", 2, current_trans, current_ease, 2)
	else:
		follow.hide()
		follow_2.hide()

	tween.set_repeat(repeat_mode.is_pressed())
	tween.start()
	tween.seek(pos)

	if paused_mode.is_pressed():
		tween.stop_all()


func _on_Tween_tween_step(_object, _key, elapsed, _value):
	var runtime = tween.get_runtime()
	var ratio = 100 * (elapsed / runtime)
	timeline.set_value(ratio)


func _on_Timeline_value_changed(value):
	if not paused_mode.is_pressed():
		return
	var runtime = tween.get_runtime()
	tween.seek(runtime * value / 100)


func on_callback(arg):
	area_label.add_text("on_callback -> " + arg + "\n")
