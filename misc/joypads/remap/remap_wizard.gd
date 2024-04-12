extends Node


const DEADZONE = 0.3

var joy_guid = ""
var joy_name = ""

var steps = JoyMapping.BASE.keys()
var cur_step = -1
var cur_mapping = {}
var last_mapping = ""

@onready var joy_buttons = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Buttons
@onready var joy_axes = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Axes
@onready var joy_mapping_text = $Mapping/Margin/VBox/Info/Text/Value
@onready var joy_mapping_full_axis = $Mapping/Margin/VBox/Info/Extra/FullAxis
@onready var joy_mapping_axis_invert = $Mapping/Margin/VBox/Info/Extra/InvertAxis


func _input(event):
	if cur_step == -1:
		return
	if event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		var motion = event as InputEventJoypadMotion
		if abs(motion.axis_value) > DEADZONE:
			var idx = motion.axis
			var map = JoyMapping.new(JoyMapping.TYPE.AXIS, idx)
			map.inverted = joy_mapping_axis_invert.pressed
			if joy_mapping_full_axis.pressed:
				map.axis = JoyMapping.AXIS.FULL
			elif motion.axis_value > 0:
				map.axis = JoyMapping.AXIS.HALF_PLUS
			else:
				map.axis = JoyMapping.AXIS.HALF_MINUS
			joy_mapping_text.text = map.to_human_string()
			cur_mapping[steps[cur_step]] = map
	elif event is InputEventJoypadButton and event.pressed:
		get_viewport().set_input_as_handled()
		var btn = event as InputEventJoypadButton
		var map = JoyMapping.new(JoyMapping.TYPE.BTN, btn.button_index)
		joy_mapping_text.text = map.to_human_string()
		cur_mapping[steps[cur_step]] = map


func create_mapping_string(mapping):
	var string = "%s,%s," % [joy_guid, joy_name]
	for k in mapping:
		var m = mapping[k]
		if typeof(m) == TYPE_OBJECT and m.type == JoyMapping.TYPE.NONE:
			continue
		string += "%s:%s," % [k, str(m)]
	var platform = "Unknown"
	if JoyMapping.PLATFORMS.keys().has(OS.get_name()):
		platform = JoyMapping.PLATFORMS[OS.get_name()]
	return string + "platform:" + platform


func start(idx):
	joy_guid = Input.get_joy_guid(idx)
	joy_name = Input.get_joy_name(idx)
	if joy_guid.is_empty():
		printerr("Unable to find controller")
		return
	if OS.get_name() == "HTML5":
		# Propose trying known mapping on HTML5.
		$Start.window_title = "%s - %s" % [joy_guid, joy_name]
		$Start.popup_centered()
	else:
		# Run wizard directly.
		_on_Wizard_pressed()


func remap_and_close(mapping):
	last_mapping = create_mapping_string(mapping)
	Input.add_joy_mapping(last_mapping, true)
	reset()
	show_map()


func reset():
	$Start.hide()
	$Mapping.hide()
	joy_guid = ""
	joy_name = ""
	cur_mapping = {}
	cur_step = -1


func step_next():
	$Mapping.title = "Step: %d/%d" % [cur_step + 1, steps.size()]
	joy_mapping_text.text = ""
	if cur_step >= steps.size():
		remap_and_close(cur_mapping)
	else:
		_update_step()


func show_map():
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.prompt('This is the resulting remap string', '%s')" % last_mapping)
	else:
		$MapWindow/Margin/VBoxContainer/TextEdit.text = last_mapping
		$MapWindow.popup_centered()


func _update_step():
	$Mapping/Margin/VBox/Info/Buttons/Next.grab_focus()
	for btn in joy_buttons.get_children():
		btn.hide()
	for axis in joy_axes.get_children():
		axis.hide()
	var key = steps[cur_step]
	var idx = JoyMapping.BASE[key]
	if key in ["leftx", "lefty", "rightx", "righty"]:
		joy_axes.get_node(str(idx) + "+").show()
		joy_axes.get_node(str(idx) + "-").show()
	else:
		joy_buttons.get_node(str(idx)).show()

	joy_mapping_full_axis.button_pressed = key in ["leftx", "lefty", "rightx", "righty", "righttrigger", "lefttrigger"]
	joy_mapping_axis_invert.button_pressed = false
	if cur_mapping.has(key):
		var cur = cur_mapping[steps[cur_step]]
		joy_mapping_text.text = cur.to_human_string()
		if cur.type == JoyMapping.TYPE.AXIS:
			joy_mapping_full_axis.pressed = cur.axis == JoyMapping.AXIS.FULL
			joy_mapping_axis_invert.pressed = cur.inverted


func _on_Wizard_pressed():
	Input.remove_joy_mapping(joy_guid)
	$Start.hide()
	$Mapping.popup_centered()
	cur_step = 0
	step_next()


func _on_Cancel_pressed():
	reset()


func _on_xbox_pressed():
	remap_and_close(JoyMapping.XBOX)


func _on_xboxosx_pressed():
	remap_and_close(JoyMapping.XBOX_OSX)


func _on_Mapping_popup_hide():
	reset()


func _on_Next_pressed():
	cur_step += 1
	step_next()


func _on_Prev_pressed():
	if cur_step > 0:
		cur_step -= 1
		step_next()


func _on_Skip_pressed():
	var key = steps[cur_step]
	if cur_mapping.has(key):
		cur_mapping.erase(key)
	cur_step += 1
	step_next()


func _on_FullAxis_toggled(button_pressed):
	if cur_step == -1 or not button_pressed:
		return
	var key = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.TYPE.AXIS:
		cur_mapping[key].axis = JoyMapping.AXIS.FULL
		joy_mapping_text.text = cur_mapping[key].to_human_string()


func _on_InvertAxis_toggled(button_pressed):
	if cur_step == -1:
		return
	var key = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.TYPE.AXIS:
		cur_mapping[key].inverted = button_pressed
		joy_mapping_text.text = cur_mapping[key].to_human_string()


func _on_start_close_requested():
	$Start.hide()


func _on_mapping_close_requested():
	$Mapping.hide()


func _on_map_window_close_requested():
	$MapWindow.hide()
