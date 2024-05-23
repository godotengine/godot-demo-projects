extends Control

# Joypads demo, written by Dana Olson <dana@shineuponthee.com>
#
# This is a demo of joypad support, and doubles as a testing application
# inspired by and similar to jstest-gtk.
#
# Licensed under the MIT license

const DEADZONE = 0.2
const FONT_COLOR_DEFAULT = Color(1.0, 1.0, 1.0, 0.5)
const FONT_COLOR_ACTIVE = Color(0.2, 1.0, 0.2, 1.0)

var joy_num := 0
var cur_joy := -1
var axis_value := 0.0

@onready var axes: VBoxContainer = $Axes
@onready var button_grid: GridContainer = $Buttons/ButtonGrid
@onready var joypad_axes: Node2D = $JoypadDiagram/Axes
@onready var joypad_buttons: Node2D = $JoypadDiagram/Buttons
@onready var joypad_name: RichTextLabel = $DeviceInfo/JoyName
@onready var joypad_number: SpinBox = $DeviceInfo/JoyNumber

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	for joypad in Input.get_connected_joypads():
		print_rich("Found joypad #%d: [b]%s[/b] - %s" % [joypad, Input.get_joy_name(joypad), Input.get_joy_guid(joypad)])

func _process(_delta: float) -> void:
	# Get the joypad device number from the spinbox.
	joy_num = int(joypad_number.value)

	# Display the name of the joypad if we haven't already.
	if joy_num != cur_joy:
		cur_joy = joy_num
		if Input.get_joy_name(joy_num) != "":
			set_joypad_name(Input.get_joy_name(joy_num), Input.get_joy_guid(joy_num))
		else:
			clear_joypad_name()


	# Loop through the axes and show their current values.
	for axis in range(int(min(JOY_AXIS_MAX, 10))):
		axis_value = Input.get_joy_axis(joy_num, axis)
		axes.get_node("Axis" + str(axis) + "/ProgressBar").set_value(100 * axis_value)
		axes.get_node("Axis" + str(axis) + "/ProgressBar/Value").set_text("[center][fade start=2 length=16]%s[/fade][/center]" % axis_value)
		# Scaled value used for alpha channel using valid range rather than including unusable deadzone values.
		var scaled_alpha_value: float = (abs(axis_value) - DEADZONE) / (1.0 - DEADZONE)
		# Show joypad direction indicators
		if axis <= JOY_AXIS_RIGHT_Y:
			if abs(axis_value) < DEADZONE:
				joypad_axes.get_node(str(axis) + "+").hide()
				joypad_axes.get_node(str(axis) + "-").hide()
			elif axis_value > 0:
				joypad_axes.get_node(str(axis) + "+").show()
				joypad_axes.get_node(str(axis) + "-").hide()
				# Transparent white modulate, non-alpha color channels are not changed here.
				joypad_axes.get_node(str(axis) + "+").self_modulate.a = scaled_alpha_value
			else:
				joypad_axes.get_node(str(axis) + "+").hide()
				joypad_axes.get_node(str(axis) + "-").show()
				# Transparent white modulate, non-alpha color channels are not changed here.
				joypad_axes.get_node(str(axis) + "-").self_modulate.a = scaled_alpha_value
		elif axis == JOY_AXIS_TRIGGER_LEFT || axis == JOY_AXIS_TRIGGER_RIGHT:
			if axis_value <= DEADZONE:
				joypad_axes.get_node(str(axis)).hide()
			else:
				joypad_axes.get_node(str(axis)).show()
				# Transparent white modulate, non-alpha color channels are not changed here.
				joypad_axes.get_node(str(axis)).self_modulate.a = scaled_alpha_value

		# Highlight axis labels that are within the "active" value range. Simular to the button highlighting for loop below.
		axes.get_node("Axis" + str(axis) + "/Label").add_theme_color_override("font_color", FONT_COLOR_DEFAULT)
		if abs(axis_value) >= DEADZONE:
			axes.get_node("Axis" + str(axis) + "/Label").add_theme_color_override("font_color", FONT_COLOR_ACTIVE)

	# Loop through the buttons and highlight the ones that are pressed.
	for button in range(int(min(JOY_BUTTON_SDL_MAX, 21))):
		if Input.is_joy_button_pressed(joy_num, button):
			button_grid.get_child(button).add_theme_color_override("font_color", FONT_COLOR_ACTIVE)
			if button <= JOY_BUTTON_MISC1:
				joypad_buttons.get_child(button).show()
		else:
			button_grid.get_child(button).add_theme_color_override("font_color", FONT_COLOR_DEFAULT)
			if button <= JOY_BUTTON_MISC1:
				joypad_buttons.get_child(button).hide()


# Called whenever a joypad has been connected or disconnected.
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		print_rich("[color=green][b]+[/b] Found newly connected joypad #%d: [b]%s[/b] - %s[/color]" % [device_id, Input.get_joy_name(device_id), Input.get_joy_guid(device_id)])
	else:
		print_rich("[color=red][b]-[/b] Disconnected joypad #%d.[/color]" % device_id)

	if device_id == cur_joy:
		# Update current joypad label.
		if connected:
			set_joypad_name(Input.get_joy_name(device_id), Input.get_joy_guid(device_id))
		else:
			clear_joypad_name()


func _on_start_vibration_pressed() -> void:
	var weak: float = $Vibration/Weak/Value.get_value()
	var strong: float = $Vibration/Strong/Value.get_value()
	var duration: float = $Vibration/Duration/Value.get_value()
	Input.start_joy_vibration(cur_joy, weak, strong, duration)


func _on_stop_vibration_pressed() -> void:
	Input.stop_joy_vibration(cur_joy)


func _on_Remap_pressed() -> void:
	$RemapWizard.start(cur_joy)


func _on_Clear_pressed() -> void:
	var guid := Input.get_joy_guid(cur_joy)
	if guid.is_empty():
		push_error("No gamepad selected.")
		return

	Input.remove_joy_mapping(guid)


func _on_Show_pressed() -> void:
	$RemapWizard.show_map()


func _on_joy_name_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func set_joypad_name(joy_name: String, joy_guid: String) -> void:
	# Make the GUID clickable (and point to Godot's game controller database for easier lookup).
	joypad_name.set_text("%s\n[color=#fff9][url=https://github.com/godotengine/godot/blob/master/core/input/gamecontrollerdb.txt]%s[/url][/color]" % [joy_name, joy_guid])

	# Make the rest of the UI appear as enabled.
	for node: CanvasItem in [$JoypadDiagram, $Axes, $Buttons, $Vibration, $VBoxContainer]:
		node.modulate.a = 1.0

func clear_joypad_name() -> void:
	joypad_name.set_text("[i]No controller detected at ID %d.[/i]" % joypad_number.value)

	# Make the rest of the UI appear as disabled.
	for node: CanvasItem in [$JoypadDiagram, $Axes, $Buttons, $Vibration, $VBoxContainer]:
		node.modulate.a = 0.5
