extends Node3D

@onready var sssr_button = $UI/MarginContainer/VBoxContainer/SSSR
@onready var gray_scale_button = $UI/MarginContainer/VBoxContainer/GrayScaleBtn

var create_depth_mips_effect : RenderingEffectCreateDepthMips
var apply_sssr_effect : RenderingEffectApplySSSR
var gray_scale_effect : RenderingEffectGrayScale

# Called when the node enters the scene tree for the first time.
func _ready():
	var environment : Environment = $WorldEnvironment.environment
	for effect in environment.rendering_effects:
		if effect.get_script() == RenderingEffectCreateDepthMips:
			create_depth_mips_effect = effect
		elif effect.get_script() == RenderingEffectApplySSSR:
			apply_sssr_effect = effect
		elif effect.get_script() == RenderingEffectGrayScale:
			gray_scale_effect = effect

	if create_depth_mips_effect and apply_sssr_effect:
		sssr_button.button_pressed = create_depth_mips_effect.enabled

	if gray_scale_effect:
		gray_scale_button.button_pressed = gray_scale_effect.enabled

var cam_x = 0.0
var cam_y = 0.0

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_event : InputEventMouseMotion = event

		if mouse_event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			cam_x = clamp(cam_x + mouse_event.relative.y * 0.01, -PI * 0.1, PI * 0.25)
			cam_y -= mouse_event.relative.x * 0.01

			var b1 : Basis = Basis(Vector3.UP, cam_y)
			var b2 : Basis = Basis(Vector3.LEFT, cam_x)

			$Pivot.transform.basis = b1 * b2

func _on_simple_ssr_toggled(toggled_on):
	if create_depth_mips_effect and apply_sssr_effect:
		create_depth_mips_effect.enabled = toggled_on
		apply_sssr_effect.enabled = toggled_on

func _on_gray_scale_btn_toggled(toggled_on):
	if gray_scale_effect:
		gray_scale_effect.enabled = toggled_on


