extends VBoxContainer

@export var scenes: Array[PackedScene]

var current_scene: TestScene = null
var world_environment: WorldEnvironment = null

func _ready():
	_on_scene_option_button_item_selected(0)

func _on_scene_option_button_item_selected(index):
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null

	var old_environment: Environment = null
	if world_environment != null:
		old_environment = world_environment.environment

	var new_scene: PackedScene = scenes[index]
	current_scene = new_scene.instantiate() as TestScene
	if current_scene:
		add_child(current_scene)

		world_environment = current_scene.world_environment
		if old_environment != null:
			world_environment.environment.tonemap_mode = old_environment.tonemap_mode
			world_environment.environment.tonemap_exposure = old_environment.tonemap_exposure
			world_environment.environment.tonemap_white = old_environment.tonemap_white
			world_environment.environment.adjustment_color_correction = old_environment.adjustment_color_correction
			world_environment.environment.adjustment_saturation = old_environment.adjustment_saturation


func _on_tonemap_mode_item_selected(index: int) -> void:
	world_environment.environment.tonemap_mode = index as Environment.ToneMapper
	# Hide whitepoint if not relevant (Linear and AgX tonemapping do not use a whitepoint).
	%Whitepoint.visible = world_environment.environment.tonemap_mode != Environment.TONE_MAPPER_LINEAR and world_environment.environment.tonemap_mode != Environment.TONE_MAPPER_AGX

func _on_exposure_value_changed(value: float) -> void:
	world_environment.environment.tonemap_exposure = value
	$TonemapMode/Exposure/Value.text = str(value).pad_decimals(1)


func _on_whitepoint_value_changed(value: float) -> void:
	world_environment.environment.tonemap_white = value
	$TonemapMode/Whitepoint/Value.text = str(value).pad_decimals(1)


func _on_color_correction_item_selected(index: int) -> void:
	# Use alphabetical order in the `example_luts` folder.
	match index:
		0:  # None
			world_environment.environment.adjustment_color_correction = null
		1:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/detect_white_clipping.png")
		2:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/frozen.png")
		3:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/heat.png")
		4:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/incandescent.png")
		5:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/posterized.png")
		6:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/posterized_outline.png")
		7:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/rainbow.png")
		8:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/toxic.png")
		9:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/brighten_shadows.png")
		10:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/burned_blue.png")
		11:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/cold_color.png")
		12:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/detect_white_clipping.png")
		13:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/dithered.png")
		14:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/hue_shift.png")
		15:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/posterized.png")
		16:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/sepia.png")
		17:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/stressed.png")
		18:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/warm_color.png")
		19:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/yellowen.png")


func _on_saturation_value_changed(value: float) -> void:
	world_environment.environment.adjustment_saturation = value
	$ColorCorrection/Saturation/Value.text = str(value).pad_decimals(1)


func _on_debanding_toggled(button_pressed: bool) -> void:
	get_viewport().use_debanding = button_pressed
