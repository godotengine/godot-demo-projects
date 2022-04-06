extends Control
# Window project settings:
#  - Viewport size is set to 1920x1080
#  - Stretch mode is set to "canvas_items" (in godot 3.x known as 2d)
#  - Stretch aspect is set to "expand"
@onready var sub_viewport := $SubViewportContainer/SubViewport
@onready var sub_viewport_container := $SubViewportContainer
@onready var world_environment := $WorldEnvironment

var current_quality := 2 # This is needed for when screen size changes
var viewport_start_size := Vector2.ZERO


func _ready() -> void:
	# When the screen changes size, we need to update the 3D
	# viewport quality setting. If we don't do this, the viewport will take
	# the size from the main viewport.
	viewport_start_size.x = ProjectSettings.get_setting(&"display/window/size/viewport_width")
	viewport_start_size.y = ProjectSettings.get_setting(&"display/window/size/viewport_height")
	sub_viewport.connect(&"size_changed", self._on_quality_option_button_item_selected)


func _on_HideShowButton_toggled(show_settings: bool) -> void:
	# Option to hide the settings so you can see the changes to the 3d world better.
	var button := $HideShowButton
	var settings_menu := $SettingsMenu
	if show_settings:
		button.text = "Hide settings"
	else:
		button.text = "Show settings"
	settings_menu.visible = show_settings


func _on_ui_scale_option_button_item_selected(index: int) -> void:
	# For changing the UI, we take the viewport size, which we set in the project settings.
	var new_size := viewport_start_size
	if index == 0: # Extra small
		new_size *= 1.50
	elif index == 1: # Small
		new_size *= 1.25
	elif index == 2: # Normal
		new_size *= 1.0
	elif index == 3: # Big
		new_size *= 0.75
	elif index == 4: # Extra big
		new_size *= 0.50
	get_tree().root.set_content_scale_size(new_size)


func _on_quality_option_button_item_selected(index: int = current_quality) -> void:
	# Setting the overal screen quality can be done by changing
	# the sub viewport size. When the screen size changed, this function
	# will get called with the current_quality variable.
	var new_size : Vector2
	current_quality = index
	if index == 0: # Extra low
		new_size = get_viewport().size * 0.50
	elif index == 1: # Low
		new_size = get_viewport().size * 0.75
	elif index == 2: # Medium
		new_size = get_viewport().size
	elif index == 3: # High
		new_size = get_viewport().size * 1.25
	elif index == 4: # Extra high
		new_size = get_viewport().size * 1.50
	sub_viewport.set_size(new_size)


func _on_filter_option_button_item_selected(index: int) -> void:
	# Texture filter setting. This can smooth out hard edges, but can also make
	# the scene appear more blurry when quality is set to low.
	if index == 0: # Disabled
		sub_viewport_container.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	elif index == 1: # Enabled
		sub_viewport_container.set_texture_filter(CanvasItem.TEXTURE_FILTER_LINEAR)


func _on_vsync_option_button_item_selected(index: int) -> void:
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible.
	if index == 0: # Disabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_aa_option_button_item_selected(index: int) -> void:
	# Because this option is only for the 3D objects, we need to
	# change this setting on the sub viewport.
	# MSAA = Better quality at a higher performance cost.
	# FXAA = Low performance cost but can appear blurry.
	if index == 0: # Disabled
		sub_viewport.set_msaa(Viewport.MSAA_DISABLED)
		sub_viewport.set_screen_space_aa(Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 1: # FXAA
		sub_viewport.set_msaa(Viewport.MSAA_DISABLED)
		sub_viewport.set_screen_space_aa(Viewport.SCREEN_SPACE_AA_FXAA)
	elif index == 2: # 2x
		sub_viewport.set_msaa(Viewport.MSAA_2X)
		sub_viewport.set_screen_space_aa(Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 3: # 4x
		sub_viewport.set_msaa(Viewport.MSAA_4X)
		sub_viewport.set_screen_space_aa(Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 4: # 8x
		sub_viewport.set_msaa(Viewport.MSAA_8X)
		sub_viewport.set_screen_space_aa(Viewport.SCREEN_SPACE_AA_DISABLED)


func _on_fullscreen_option_button_item_selected(index: int) -> void:
	# To change between winow, fullscreen and other window modes,
	# set the root mode to one of the options of Window.MODE_*.
	# other modes are maximized, minimized and exclusive fullscreen.
	if index == 0:
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1:
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)


func _on_ss_reflections_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.set_ssr_enabled(false)
	elif index == 1: # Low
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(8)
	elif index == 2: # Medium
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(32)
	elif index == 3: # High
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(64)
	# We set the fade in higher (default is 0.15) so it looks
	# a better and cleaner.
	world_environment.environment.set_ssr_fade_in(0.7)

func _on_ssao_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.set_ssao_enabled(false)
	elif index == 1: # Enabled
		world_environment.environment.set_ssao_enabled(true)


func _on_ssil_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.set_ssil_enabled(false)
	elif index == 1: # Enabled
		world_environment.environment.set_ssil_enabled(true)


func _on_sdfgi_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.set_sdfgi_enabled(false)
	elif index == 1: # Enabled
		world_environment.environment.set_sdfgi_enabled(true)


func _on_glow_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.set_glow_enabled(false)
	elif index == 1: # Enabled
		world_environment.environment.set_glow_enabled(true)


func _on_brightness_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	# The slider value is clammed between 0.5 and 4.
	world_environment.environment.set_adjustment_brightness(value)


func _on_contrast_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	# The slider value is clammed between 0.5 and 4.
	world_environment.environment.set_adjustment_contrast(value)


func _on_saturation_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	# The slider value is clammed between 0.5 and 10.
	world_environment.environment.set_adjustment_saturation(value)
