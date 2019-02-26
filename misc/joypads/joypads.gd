extends Node2D

# Joypads demo, written by Dana Olson <dana@shineuponthee.com>
#
# This is a demo of joypad support, and doubles as a testing application
# inspired by and similar to jstest-gtk.
#
# Licensed under the MIT license

# Member variables
var joy_num
var cur_joy = -1
var axis_value

const DEADZONE = 0.2

func _physics_process(_delta):
	# Get the joypad device number from the spinbox
	joy_num = get_node("device_info/joy_num").get_value()

	# Display the name of the joypad if we haven't already
	if joy_num != cur_joy:
		cur_joy = joy_num
		get_node("device_info/joy_name").set_text(Input.get_joy_name(joy_num))

	# Loop through the axes and show their current values
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		axis_value = Input.get_joy_axis(joy_num, axis)
		get_node("axes/axis_prog" + str(axis)).set_value(100*axis_value)
		get_node("axes/axis_val" + str(axis)).set_text(str(axis_value))
		# Show joypad direction indicators
		if axis <= JOY_ANALOG_RY:
			if abs(axis_value) < DEADZONE:
				get_node("diagram/axes/" + str(axis) + "+").hide()
				get_node("diagram/axes/" + str(axis) + "-").hide()
			elif axis_value > 0:
				get_node("diagram/axes/" + str(axis) + "+").show()
				get_node("diagram/axes/" + str(axis) + "-").hide()
			else:
				get_node("diagram/axes/" + str(axis) + "+").hide()
				get_node("diagram/axes/" + str(axis) + "-").show()

	# Loop through the buttons and highlight the ones that are pressed
	for btn in range(JOY_BUTTON_0, JOY_BUTTON_MAX):
		if Input.is_joy_button_pressed(joy_num, btn):
			get_node("buttons/btn" + str(btn)).add_color_override("font_color", Color(1, 1, 1, 1))
			get_node("diagram/buttons/" + str(btn)).show()
		else:
			get_node("buttons/btn" + str(btn)).add_color_override("font_color", Color(0.2, 0.1, 0.3, 1))
			get_node("diagram/buttons/" + str(btn)).hide()

func _ready():
	set_physics_process(true)
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

#Called whenever a joypad has been connected or disconnected.
func _on_joy_connection_changed(device_id, connected):
	if device_id == cur_joy:
		if connected:
			get_node("device_info/joy_name").set_text(Input.get_joy_name(device_id))
		else:
			get_node("device_info/joy_name").set_text("")

func _on_start_vibration_pressed():
	var weak = get_node("vibration/vibration_weak_value").get_value()
	var strong = get_node("vibration/vibration_strong_value").get_value()
	var duration = get_node("vibration/vibration_duration_value").get_value()

	Input.start_joy_vibration(cur_joy, weak, strong, duration)

func _on_stop_vibration_pressed():
	Input.stop_joy_vibration(cur_joy)
