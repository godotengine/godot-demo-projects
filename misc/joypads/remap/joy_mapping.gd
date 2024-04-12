extends RefCounted
class_name JoyMapping


enum TYPE {NONE, BTN, AXIS}
enum AXIS {FULL, HALF_PLUS, HALF_MINUS}

const PLATFORMS = {
	# From gamecontrollerdb
	"Windows": "Windows",
	"OSX": "Mac OS X",
	"X11": "Linux",
	"Android": "Android",
	"iOS": "iOS",
	# Godot customs
	"HTML5": "Javascript",
	"UWP": "UWP",
	# 4.x compat
	"Linux": "Linux",
	"FreeBSD": "Linux",
	"NetBSD": "Linux",
	"BSD": "Linux",
	"macOS": "Mac OS X",
}

const BASE = {
	# Buttons
	"a": JOY_BUTTON_A,
	"b": JOY_BUTTON_B,
	"y": JOY_BUTTON_Y,
	"x": JOY_BUTTON_X,
	"start": JOY_BUTTON_START,
	"back": JOY_BUTTON_BACK,
	"leftstick": JOY_BUTTON_LEFT_STICK,
	"rightstick": JOY_BUTTON_RIGHT_STICK,
	"leftshoulder": JOY_BUTTON_LEFT_SHOULDER,
	"rightshoulder": JOY_BUTTON_RIGHT_SHOULDER,
	"dpup": JOY_BUTTON_DPAD_UP,
	"dpleft": JOY_BUTTON_DPAD_LEFT,
	"dpdown": JOY_BUTTON_DPAD_DOWN,
	"dpright": JOY_BUTTON_DPAD_RIGHT,

	# Axis
	"leftx": JOY_AXIS_LEFT_X,
	"lefty": JOY_AXIS_LEFT_Y,
	"rightx": JOY_AXIS_RIGHT_X,
	"righty": JOY_AXIS_RIGHT_Y,
	"lefttrigger": JOY_AXIS_TRIGGER_LEFT,
	"righttrigger": JOY_AXIS_TRIGGER_RIGHT,
}

const XBOX = {
	"a": "b0",
	"b": "b1",
	"y": "b3",
	"x": "b2",
	"start": "b7",
	"guide": "b8",
	"back": "b6",
	"leftstick": "b9",
	"rightstick": "b10",
	"leftshoulder": "b4",
	"rightshoulder": "b5",
	"dpup": "-a7",
	"dpleft":"-a6",
	"dpdown": "+a7",
	"dpright": "+a6",
	"leftx": "a0",
	"lefty": "a1",
	"rightx": "a3",
	"righty": "a4",
	"lefttrigger": "a2",
	"righttrigger": "a5",
}

const XBOX_OSX = {
	"a": "b11",
	"b": "b12",
	"y": "b14",
	"x": "b13",
	"start": "b4",
	"back": "b5",
	"leftstick": "b6",
	"rightstick": "b7",
	"leftshoulder": "b8",
	"rightshoulder": "b9",
	"dpup": "b0",
	"dpleft": "b2",
	"dpdown": "b1",
	"dpright": "b3",
	"leftx": "a0",
	"lefty": "a1",
	"rightx": "a2",
	"righty": "a3",
	"lefttrigger": "a4",
	"righttrigger":"a5",
}

var type = TYPE.NONE
var idx = -1
var axis = AXIS.FULL
var inverted = false


func _init(p_type = TYPE.NONE, p_idx = -1, p_axis = AXIS.FULL):
	type = p_type
	idx = p_idx
	axis = p_axis


func _to_string():
	if type == TYPE.NONE:
		return ""
	var ts = "b" if type == TYPE.BTN else "a"
	var prefix = ""
	var suffix = "~" if inverted else ""
	match axis:
		AXIS.HALF_PLUS:
			prefix = "+"
		AXIS.HALF_MINUS:
			prefix = "-"
	return "%s%s%d%s" % [prefix, ts, idx, suffix]


func to_human_string():
	if type == TYPE.BTN:
		return "Button %d" % idx
	if type == TYPE.AXIS:
		var prefix = ""
		match axis:
			AXIS.HALF_PLUS:
				prefix = "(+) "
			AXIS.HALF_MINUS:
				prefix = "(-) "
		var suffix = " (inverted)" if inverted else ""
		return "Axis %s%d%s" % [prefix, idx, suffix]
	return ""
