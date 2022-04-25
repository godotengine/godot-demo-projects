extends Control

# Window project settings:
#  - Stretch mode is set to `canvas_items` (`2d` in Godot 3.x)
#  - Stretch aspect is set to `expand`
@onready var world_environment := $WorldEnvironment
@onready var camera := $Node3D/Camera3D
@onready var fps_label := $FPSLabel
@onready var resolution_label := $ResolutionLabel

# When the screen changes size, we need to update the 3D
# viewport quality setting. If we don't do this, the viewport will take
# the size from the main viewport.
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)


func _ready() -> void:
	get_viewport().connect(&"size_changed", update_resolution_label)
	update_resolution_label()

	# Disable V-Sync to uncap framerate on supported platforms. This makes performance comparison
	# easier on high-end machines that easily reach the monitor's refresh rate.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _process(delta: float) -> void:
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]


func update_resolution_label() -> void:
	var viewport_render_size = get_viewport().size * get_viewport().scaling_3d_scale
	resolution_label.text = "3D viewport resolution: %d × %d (%d%%)" \
			% [viewport_render_size.x, viewport_render_size.y, round(get_viewport().scaling_3d_scale * 100)]


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
	if index == 0: # Smaller (66%)
		new_size *= 1.5
	elif index == 1: # Small (80%)
		new_size *= 1.25
	elif index == 2: # Medium (100%)
		new_size *= 1.0
	elif index == 3: # Large (133%)
		new_size *= 0.75
	elif index == 4: # Larger (200%)
		new_size *= 0.5
	get_tree().root.set_content_scale_size(new_size)


func _on_quality_slider_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value
	update_resolution_label()


func _on_filter_option_button_item_selected(index: int) -> void:
	# Viewport scale mode setting.
	if index == 0: # Bilinear (Fastest)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	elif index == 1: # FSR 1.0 (Fast)
		push_warning("FSR is currently not working. The shader is run, but no visual difference appears on screen.")
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR


func _on_vsync_option_button_item_selected(index: int) -> void:
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible at the cost of
	# higher input latency and stuttering when the framerate target is not met.
	# Adaptive V-Sync automatically disables V-Sync when the framerate target is not met, and enables
	# V-Sync otherwise. This prevents suttering and reduces input latency when the framerate target
	# is not met, at the cost of visible tearing.
	if index == 0: # Disabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_aa_option_button_item_selected(index: int) -> void:
	# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
	# transparent (alpha scissor) textures.
	if index == 0: # Disabled
		get_viewport().msaa = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa = Viewport.MSAA_8X


func _on_fxaa_option_button_item_selected(index: int) -> void:
	# Fast approximate anti-aliasing. Much faster than FXAA (and works on alpha scissor edges),
	# but blurs the whole scene rendering slightly.
	get_viewport().screen_space_aa = index == 1


func _on_fullscreen_option_button_item_selected(index: int) -> void:
	# To change between winow, fullscreen and other window modes,
	# set the root mode to one of the options of Window.MODE_*.
	# other modes are maximized, minimized and exclusive fullscreen.
	if index == 0:
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1:
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)


func _on_fov_slider_value_changed(value: float) -> void:
	camera.fov = value


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
		world_environment.environment.set_ssr_max_steps(56)


func _on_ssao_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.ssao_enabled = false
	if index == 1: # Very Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 2: # Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 3: # Medium
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if index == 4: # High
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)


func _on_ssil_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.ssil_enabled = false
	if index == 1: # Very Low
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
	if index == 2: # Low
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
	if index == 3: # Medium
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
	if index == 4: # High
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)


func _on_sdfgi_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.sdfgi_enabled = false
	if index == 1: # Low
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(true)
	if index == 2: # High
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(false)


func _on_glow_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to set the settings correct.
	if index == 0: # Disabled
		world_environment.environment.glow_enabled = false
	if index == 1: # Low
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_high_quality(false)
	if index == 2: # High
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_high_quality(true)


func _on_volumetric_fog_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled
		world_environment.environment.volumetric_fog_enabled = false
	if index == 1: # Low
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(false)
	if index == 2: # High
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(true)


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
