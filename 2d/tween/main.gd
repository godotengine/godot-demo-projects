extends Control

const trans_list = ["Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back"]
const eases_list = ["In", "Out", "InOut", "OutIn"]
const modes_list = ["Move", "Color", "Scale", "Rotate", "Callback", "Follow", "Repeat", "Pause"]

var state = {
	trans = Tween.TRANS_LINEAR,
	eases = Tween.EASE_IN,
}

onready var trans = $Trans
onready var eases = $Eases
onready var modes = $Modes
onready var tween = $Tween
onready var timeline = $Timeline
onready var color_from_picker = $Colors/ColorFrom/Picker
onready var color_to_picker = $Colors/ColorTo/Picker
onready var sprite = $Tween/Area/Sprite
onready var follow = $Tween/Area/Follow
onready var follow_2 = $Tween/Area/Follow2
onready var size = $Tween/Area.get_size()

func _ready():
	for index in range(trans_list.size()):
		trans.get_node(trans_list[index]).connect("pressed", self, "on_trans_changed", [trans_list[index], index])

	for index in range(eases_list.size()):
		eases.get_node(eases_list[index]).connect("pressed", self, "on_eases_changed", [eases_list[index], index])

	for index in range(modes_list.size()):
		modes.get_node(modes_list[index]).connect("pressed", self, "on_modes_changed", [modes_list[index]])

	color_from_picker.set_pick_color(Color.red)
	color_from_picker.connect("color_changed", self, "on_color_changed")

	color_to_picker.set_pick_color(Color.cyan)
	color_to_picker.connect("color_changed", self, "on_color_changed")

	$Trans/Linear.set_pressed(true)
	$Eases/In.set_pressed(true)
	$Modes/Move.set_pressed(true)
	$Modes/Repeat.set_pressed(true)

	reset_tween()


func on_trans_changed(trans_name, index):
	for index in range(trans_list.size()):
		var pressed = trans_list[index] == trans_name
		var btn = trans.get_node(trans_list[index])

		btn.set_pressed(pressed)
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE if pressed else Control.MOUSE_FILTER_PASS)

	state.trans = index
	reset_tween()


func on_eases_changed(ease_name, index):
	for index in range(eases_list.size()):
		var pressed = eases_list[index] == ease_name
		var btn = eases.get_node(eases_list[index])

		btn.set_pressed(pressed)
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE if pressed else Control.MOUSE_FILTER_PASS)

	state.eases = index
	reset_tween()


func on_modes_changed(mode_name):
	if mode_name == "pause":
		if $Modes/Pause.is_pressed():
			tween.stop_all()
			timeline.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		else:
			tween.resume_all()
			timeline.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	else:
		reset_tween()


func on_color_changed(_color):
	reset_tween()


func reset_tween():
	var pos = tween.tell()
	tween.reset_all()
	tween.remove_all()

	if $Modes/Move.is_pressed():
		tween.interpolate_method(sprite, "set_position", Vector2(0, 0), Vector2(size.x, size.y), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "position", Vector2(size.x, size.y), Vector2(0, 0), 2, state.trans, state.eases, 2)

	if $Modes/Color.is_pressed():
		tween.interpolate_method(sprite, "set_modulate", color_from_picker.get_pick_color(), color_to_picker.get_pick_color(), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "modulate", color_to_picker.get_pick_color(), color_from_picker.get_pick_color(), 2, state.trans, state.eases, 2)
	else:
		sprite.set_modulate(Color.white)

	if $Modes/Scale.is_pressed():
		tween.interpolate_method(sprite, "set_scale", Vector2(0.5, 0.5), Vector2(1.5, 1.5), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "scale", Vector2(1.5, 1.5), Vector2(0.5, 0.5), 2, state.trans, state.eases, 2)
	else:
		sprite.set_scale(Vector2.ONE)

	if $Modes/Rotate.is_pressed():
		tween.interpolate_method(sprite, "set_rotation_degrees", 0, 360, 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "rotation_degrees", 360, 0, 2, state.trans, state.eases, 2)

	if $Modes/Callback.is_pressed():
		tween.interpolate_callback(self, 0.5, "on_callback", "0.5 seconds after")
		tween.interpolate_callback(self, 0.2, "on_callback", "1.2 seconds after")

	if $Modes/Follow.is_pressed():
		follow.show()
		follow_2.show()

		tween.follow_method(follow, "set_position", Vector2(0, size.y), sprite, "get_position", 2, state.trans, state.eases)
		tween.targeting_method(follow, "set_position", sprite, "get_position", Vector2(0, size.y), 2, state.trans, state.eases, 2)

		tween.targeting_property(follow_2, "position", sprite, "position", Vector2(size.x, 0), 2, state.trans, state.eases)
		tween.follow_property(follow_2, "position", Vector2(size.x, 0), sprite, "position", 2, state.trans, state.eases, 2)
	else:
		follow.hide()
		follow_2.hide()

	tween.set_repeat($Modes/Repeat.is_pressed())
	tween.start()
	tween.seek(pos)

	if $Modes/Pause.is_pressed():
		tween.stop_all()
		#get_node("timeline").set_ignore_mouse(false)
		timeline.set_value(0)
	else:
		tween.resume_all()
		#get_node("timeline").set_ignore_mouse(true)


func _on_tween_step(_object, _key, elapsed, _value):
	var runtime = tween.get_runtime()
	var ratio = 100 * (elapsed / runtime)
	timeline.set_value(ratio)


func _on_timeline_value_changed(value):
	if !$Modes/Pause.is_pressed():
		return
	var runtime = tween.get_runtime()
	tween.seek(runtime * value / 100)


func on_callback(arg):
	$Tween/Area/Label.add_text("on_callback -> " + arg + "\n")
