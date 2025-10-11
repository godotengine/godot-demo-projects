extends Control

@export var controller: XRController3D

@onready var trigger_input_node: HSlider = $VBoxContainer/TriggerInput/HSlider
@onready var trigger_click_node: CheckBox = $VBoxContainer/TriggerInput/CheckBox
@onready var on_threshold_node: Label = $VBoxContainer/Thresholds/OnThreshold
@onready var off_threshold_node: Label = $VBoxContainer/Thresholds/OffThreshold

@onready var dpad_up_node: CheckBox = $VBoxContainer/DPadState/Up
@onready var dpad_down_node: CheckBox = $VBoxContainer/DPadState/Down
@onready var dpad_left_node: CheckBox = $VBoxContainer/DPadState/Left
@onready var dpad_right_node: CheckBox = $VBoxContainer/DPadState/Right

var off_trigger_threshold: float = 1.0
var on_trigger_threshold: float = 0.0


func _process(_delta: float) -> void:
	if controller:
		var trigger_input = controller.get_float(&"trigger")
		trigger_input_node.value = trigger_input

		var trigger_click = controller.is_button_pressed(&"trigger_click")
		trigger_click_node.button_pressed = trigger_click

		if trigger_click:
			off_trigger_threshold = min(off_trigger_threshold, trigger_input)
		else:
			on_trigger_threshold = max(on_trigger_threshold, trigger_input)

		on_threshold_node.text = "On: %0.2f" % on_trigger_threshold
		off_threshold_node.text = "Off: %0.2f" % off_trigger_threshold

		dpad_up_node.button_pressed = controller.is_button_pressed(&"up")
		dpad_down_node.button_pressed = controller.is_button_pressed(&"down")
		dpad_left_node.button_pressed = controller.is_button_pressed(&"left")
		dpad_right_node.button_pressed = controller.is_button_pressed(&"right")
