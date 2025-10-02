extends Node3D

var tween : Tween
var active_hand : XRController3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$XROrigin3D/LeftHand/Pointer.visible = false
	$XROrigin3D/RightHand/Pointer.visible = true
	active_hand = $XROrigin3D/RightHand


# Callback for our tween to set the energy level on our active pointer.
func _update_energy(new_value : float):
	var pointer = active_hand.get_node("Pointer")
	var material : ShaderMaterial = pointer.material_override
	if material:
		material.set_shader_parameter("energy", new_value)


# Start our tween to show a pulse on our click.
func _do_tween_energy():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_method(_update_energy, 5.0, 1.0, 0.5)


# Called if left hand trigger is pressed.
func _on_left_hand_button_pressed(action_name):
	if action_name == "select":
		# Make the left hand the active pointer.
		$XROrigin3D/LeftHand/Pointer.visible = true
		$XROrigin3D/RightHand/Pointer.visible = false

		active_hand = $XROrigin3D/LeftHand
		$XROrigin3D/OpenXRCompositionLayerEquirect.controller = active_hand

		# Make a visual pulse.
		_do_tween_energy()

		# And make us feel it.
		# NOTE: `frequence == 0.0` => XR runtime chooses optimal frequency for a given controller.
		active_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)


# Called if right hand trigger is pressed.
func _on_right_hand_button_pressed(action_name):
	if action_name == "select":
		# Make the right hand the active pointer.
		$XROrigin3D/LeftHand/Pointer.visible = false
		$XROrigin3D/RightHand/Pointer.visible = true

		active_hand = $XROrigin3D/RightHand
		$XROrigin3D/OpenXRCompositionLayerEquirect.controller = active_hand

		# Make a visual pulse.
		_do_tween_energy()

		# And make us feel it.
		# NOTE: `frequence == 0.0` => XR runtime chooses optimal frequency for a given controller.
		active_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)
