
extends Control

# Member variables
var trans = ["linear", "sine", "quint", "quart", "quad", "expo", "elastic", "cubic", "circ", "bounce", "back"]
var eases = ["in", "out", "in_out", "out_in"]
var modes = ["move", "color", "scale", "rotate", "callback", "follow", "repeat", "pause"]

var state = {
	trans = Tween.TRANS_LINEAR,
	eases = Tween.EASE_IN,
}


func _ready():
	for index in range(trans.size()):
		get_node("trans/" + trans[index]).connect("pressed", self, "on_trans_changed", [trans[index], index])

	for index in range(eases.size()):
		get_node("eases/" + eases[index]).connect("pressed", self, "on_eases_changed", [eases[index], index])

	for index in range(modes.size()):
		get_node("modes/" + modes[index]).connect("pressed", self, "on_modes_changed", [modes[index]])

	get_node("colors/color_from/picker").set_pick_color(Color(1, 0, 0, 1))
	get_node("colors/color_from/picker").connect("color_changed", self, "on_color_changed")

	get_node("colors/color_to/picker").set_pick_color(Color(0, 1, 1, 1))
	get_node("colors/color_to/picker").connect("color_changed", self, "on_color_changed")

	get_node("trans/linear").set_pressed(true)
	get_node("eases/in").set_pressed(true)
	get_node("modes/move").set_pressed(true)
	get_node("modes/repeat").set_pressed(true)

	reset_tween()


func on_trans_changed(trans_name, index):
	for index in range(trans.size()):
		var pressed = trans[index] == trans_name
		var btn = get_node("trans/" + trans[index])

		btn.set_pressed(pressed)
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE if pressed else Control.MOUSE_FILTER_PASS)

	state.trans = index
	reset_tween()


func on_eases_changed(ease_name, index):
	for index in range(eases.size()):
		var pressed = eases[index] == ease_name
		var btn = get_node("eases/" + eases[index])

		btn.set_pressed(pressed)
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE if pressed else Control.MOUSE_FILTER_PASS)

	state.eases = index
	reset_tween()


func on_modes_changed(mode_name):
	var tween = get_node("tween")
	if mode_name == "pause":
		if get_node("modes/pause").is_pressed():
			tween.stop_all()
			get_node("timeline").set_mouse_filter(Control.MOUSE_FILTER_PASS)
		else:
			tween.resume_all()
			get_node("timeline").set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	else:
		reset_tween()


func on_color_changed(_color):
	reset_tween()


func reset_tween():
	var tween = get_node("tween")
	var pos = tween.tell()
	tween.reset_all()
	tween.remove_all()

	var sprite = get_node("tween/area/sprite")
	var follow = get_node("tween/area/follow")
	var follow_2 = get_node("tween/area/follow_2")
	var size = get_node("tween/area").get_size()

	if get_node("modes/move").is_pressed():
		tween.interpolate_method(sprite, "set_position", Vector2(0, 0), Vector2(size.x, size.y), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "position", Vector2(size.x, size.y), Vector2(0, 0), 2, state.trans, state.eases, 2)

	if get_node("modes/color").is_pressed():
		tween.interpolate_method(sprite, "set_modulate", get_node("colors/color_from/picker").get_pick_color(), get_node("colors/color_to/picker").get_pick_color(), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "modulate", get_node("colors/color_to/picker").get_pick_color(), get_node("colors/color_from/picker").get_pick_color(), 2, state.trans, state.eases, 2)
	else:
		sprite.set_modulate(Color(1, 1, 1, 1))

	if get_node("modes/scale").is_pressed():
		tween.interpolate_method(sprite, "set_scale", Vector2(0.5, 0.5), Vector2(1.5, 1.5), 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "scale", Vector2(1.5, 1.5), Vector2(0.5, 0.5), 2, state.trans, state.eases, 2)
	else:
		sprite.set_scale(Vector2(1, 1))

	if get_node("modes/rotate").is_pressed():
		tween.interpolate_method(sprite, "set_rotation_degrees", 0, 360, 2, state.trans, state.eases)
		tween.interpolate_property(sprite, "rotation_degrees", 360, 0, 2, state.trans, state.eases, 2)

	if get_node("modes/callback").is_pressed():
		tween.interpolate_callback(self, 0.5, "on_callback", "0.5 second's after")
		tween.interpolate_callback(self, 0.2, "on_callback", "1.2 second's after")

	if get_node("modes/follow").is_pressed():
		follow.show()
		follow_2.show()

		tween.follow_method(follow, "set_position", Vector2(0, size.y), sprite, "get_position", 2, state.trans, state.eases)
		tween.targeting_method(follow, "set_position", sprite, "get_position", Vector2(0, size.y), 2, state.trans, state.eases, 2)

		tween.targeting_property(follow_2, "position", sprite, "position", Vector2(size.x, 0), 2, state.trans, state.eases)
		tween.follow_property(follow_2, "position", Vector2(size.x, 0), sprite, "position", 2, state.trans, state.eases, 2)
	else:
		follow.hide()
		follow_2.hide()

	tween.set_repeat(get_node("modes/repeat").is_pressed())
	tween.start()
	tween.seek(pos)

	if get_node("modes/pause").is_pressed():
		tween.stop_all()
		#get_node("timeline").set_ignore_mouse(false)
		get_node("timeline").set_value(0)
	else:
		tween.resume_all()
		#get_node("timeline").set_ignore_mouse(true)


func _on_tween_step(_object, _key, elapsed, _value):
	var timeline = get_node("timeline")

	var tween = get_node("tween")
	var runtime = tween.get_runtime()

	var ratio = 100 * (elapsed / runtime)
	timeline.set_value(ratio)


func _on_timeline_value_changed(value):
	if !get_node("modes/pause").is_pressed():
		return

	var tween = get_node("tween")
	var runtime = tween.get_runtime()
	tween.seek(runtime * value / 100)


func on_callback(arg):
	var label = get_node("tween/area/label")
	label.add_text("on_callback -> " + arg + "\n")
