extends Node3D

var create_depth_mips_effect: CompositorEffectCreateDepthMips
var apply_sssr_effect: CompositorEffectApplySSSR
var gray_scale_effect: CompositorEffectGrayScale

var camera_x := 0.0
var camera_y := 0.0

@onready var sssr_button: Button = $UI/MarginContainer/VBoxContainer/SSSR
@onready var gray_scale_button: Button = $UI/MarginContainer/VBoxContainer/GrayScaleBtn

func _ready() -> void:
	var compositor: Compositor = $WorldEnvironment.compositor
	for effect in compositor.compositor_effects:
		if effect.get_script() == CompositorEffectCreateDepthMips:
			create_depth_mips_effect = effect
		elif effect.get_script() == CompositorEffectApplySSSR:
			apply_sssr_effect = effect
		elif effect.get_script() == CompositorEffectGrayScale:
			gray_scale_effect = effect

	if create_depth_mips_effect and apply_sssr_effect:
		sssr_button.button_pressed = create_depth_mips_effect.enabled

	if gray_scale_effect:
		gray_scale_button.button_pressed = gray_scale_effect.enabled


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event

		if mouse_event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			camera_x = clamp(camera_x + mouse_event.screen_relative.y * 0.01, -PI * 0.1, PI * 0.25)
			camera_y -= mouse_event.screen_relative.x * 0.01

			var b1 := Basis(Vector3.UP, camera_y)
			var b2 := Basis(Vector3.LEFT, camera_x)

			$Pivot.transform.basis = b1 * b2


func _on_simple_ssr_toggled(toggled_on: bool) -> void:
	if create_depth_mips_effect and apply_sssr_effect:
		create_depth_mips_effect.enabled = toggled_on
		apply_sssr_effect.enabled = toggled_on


func _on_gray_scale_btn_toggled(toggled_on: bool) -> void:
	if gray_scale_effect:
		gray_scale_effect.enabled = toggled_on
