extends Node

const DEADZONE = 0.3

var joy_index: int = -1
var joy_guid: String = ""
var joy_name: String = ""

var steps: Array = JoyMapping.BASE.keys()
var cur_step: int = -1
var cur_mapping: Dictionary = {}
var last_mapping: String = ""

@onready var joy_buttons: Node2D = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Buttons
@onready var joy_axes: Node2D = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Axes
@onready var joy_mapping_text: Label = $Mapping/Margin/VBox/Info/Text/Value
@onready var joy_mapping_full_axis: CheckBox = $Mapping/Margin/VBox/Info/Extra/FullAxis
@onready var joy_mapping_axis_invert: CheckBox = $Mapping/Margin/VBox/Info/Extra/InvertAxis

# Connected to Mapping.window_input, otherwise no gamepad events
# will be received when the subwindow is focused.
func _input(event: InputEvent) -> void:
	if cur_step == -1:
		return

	# Ignore events not related to gamepads.
	if event is not InputEventJoypadButton and event is not InputEventJoypadMotion:
		return

	# Ignore devices other than the one being remapped. Handles accidental input and analog drift.
	if event.device != joy_index:
		return

	if event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		var motion := event as InputEventJoypadMotion
		if abs(motion.axis_value) > DEADZONE:
			var idx := motion.axis
			var map := JoyMapping.new(JoyMapping.Type.AXIS, idx)
			map.inverted = joy_mapping_axis_invert.button_pressed
			if joy_mapping_full_axis.button_pressed:
				map.axis = JoyMapping.Axis.FULL
			elif motion.axis_value > 0:
				map.axis = JoyMapping.Axis.HALF_PLUS
			else:
				map.axis = JoyMapping.Axis.HALF_MINUS
			joy_mapping_text.text = map.to_human_string()
			cur_mapping[steps[cur_step]] = map
	elif event is InputEventJoypadButton and event.pressed:
		get_viewport().set_input_as_handled()
		var btn := event as InputEventJoypadButton
		var map := JoyMapping.new(JoyMapping.Type.BTN, btn.button_index)
		joy_mapping_text.text = map.to_human_string()
		cur_mapping[steps[cur_step]] = map


func create_mapping_string(mapping: Dictionary) -> String:
	var string := "%s,%s," % [joy_guid, joy_name]

	for k: String in mapping:
		var m: Variant = mapping[k]
		if typeof(m) == TYPE_OBJECT and m.type == JoyMapping.Type.NONE:
			continue
		string += "%s:%s," % [k, str(m)]

	var platform := "Unknown"
	if JoyMapping.PLATFORMS.keys().has(OS.get_name()):
		platform = JoyMapping.PLATFORMS[OS.get_name()]

	return string + "platform:" + platform


func start(idx: int) -> void:
	joy_index = idx
	joy_guid = Input.get_joy_guid(idx)
	joy_name = Input.get_joy_name(idx)
	if joy_guid.is_empty():
		push_error("Unable to find controller")
		return
	if OS.has_feature("web"):
		# Propose trying known mapping on Web.
		$Start.window_title = "%s - %s" % [joy_guid, joy_name]
		$Start.popup_centered()
	else:
		# Run wizard directly.
		_on_Wizard_pressed()


func remap_and_close(mapping: Dictionary) -> void:
	last_mapping = create_mapping_string(mapping)
	Input.add_joy_mapping(last_mapping, true)
	reset()
	show_map()


func reset() -> void:
	$Start.hide()
	$Mapping.hide()
	joy_guid = ""
	joy_name = ""
	cur_mapping = {}
	cur_step = -1


func step_next() -> void:
	$Mapping.title = "Step: %d/%d" % [cur_step + 1, steps.size()]
	joy_mapping_text.text = ""
	if cur_step >= steps.size():
		remap_and_close(cur_mapping)
	else:
		_update_step()


func show_map() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.prompt('This is the resulting remap string', '%s')" % last_mapping)
	else:
		$MapWindow/Margin/VBoxContainer/TextEdit.text = last_mapping
		$MapWindow.popup_centered()


func _update_step() -> void:
	$Mapping/Margin/VBox/Info/Buttons/Next.grab_focus()
	for btn in joy_buttons.get_children():
		btn.hide()
	for axis in joy_axes.get_children():
		axis.hide()
	var key: String = steps[cur_step]
	var idx: int = JoyMapping.BASE[key]
	if key in ["leftx", "lefty", "rightx", "righty"]:
		joy_axes.get_node(str(idx) + "+").show()
		joy_axes.get_node(str(idx) + "-").show()
	elif key in ["lefttrigger", "righttrigger"]:
		joy_axes.get_node(str(idx)).show()
	else:
		joy_buttons.get_node(str(idx)).show()

	joy_mapping_full_axis.button_pressed = key in ["leftx", "lefty", "rightx", "righty", "righttrigger", "lefttrigger"]
	joy_mapping_axis_invert.button_pressed = false
	if cur_mapping.has(key):
		var cur: JoyMapping = cur_mapping[steps[cur_step]]
		joy_mapping_text.text = cur.to_human_string()
		if cur.type == JoyMapping.Type.AXIS:
			joy_mapping_full_axis.button_pressed = cur.axis == JoyMapping.Axis.FULL
			joy_mapping_axis_invert.button_pressed = cur.inverted


func _on_Wizard_pressed() -> void:
	Input.remove_joy_mapping(joy_guid)
	$Start.hide()
	$Mapping.popup_centered()
	cur_step = 0
	step_next()


func _on_Cancel_pressed() -> void:
	reset()


func _on_xbox_pressed() -> void:
	remap_and_close(JoyMapping.XBOX)


func _on_xboxosx_pressed() -> void:
	remap_and_close(JoyMapping.XBOX_OSX)


func _on_Mapping_popup_hide() -> void:
	reset()


func _on_Next_pressed() -> void:
	cur_step += 1
	step_next()


func _on_Prev_pressed() -> void:
	if cur_step > 0:
		cur_step -= 1
		step_next()


func _on_Skip_pressed() -> void:
	var key: String = steps[cur_step]
	if cur_mapping.has(key):
		cur_mapping.erase(key)

	cur_step += 1
	step_next()


func _on_FullAxis_toggled(button_pressed: bool) -> void:
	if cur_step == -1 or not button_pressed:
		return

	var key: String = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.Type.AXIS:
		cur_mapping[key].axis = JoyMapping.Axis.FULL
		joy_mapping_text.text = cur_mapping[key].to_human_string()


func _on_InvertAxis_toggled(button_pressed: bool) -> void:
	if cur_step == -1:
		return

	var key: String = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.Type.AXIS:
		cur_mapping[key].inverted = button_pressed
		joy_mapping_text.text = cur_mapping[key].to_human_string()


func _on_start_close_requested() -> void:
	$Start.hide()


func _on_mapping_close_requested() -> void:
	$Mapping.hide()


func _on_map_window_close_requested() -> void:
	$MapWindow.hide()
