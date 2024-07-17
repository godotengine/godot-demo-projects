extends Control


# Window project settings:
#  - Stretch mode is set to `canvas_items` (`2d` in Godot 3.x)
#  - Stretch aspect is set to `expand`
@onready var world_environment := $WorldEnvironment
@onready var directional_light := $Node3D/DirectionalLight3D
@onready var camera := $Node3D/Camera3D
@onready var fps_label := $FPSLabel
@onready var resolution_label := $ResolutionLabel

var counter := 0.0

# When the screen changes size, we need to update the 3D
# viewport quality setting. If we don't do this, the viewport will take
# the size from the main viewport.
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)


func _ready() -> void:
	get_viewport().size_changed.connect(update_resolution_label)
	update_resolution_label()

	# Disable V-Sync to uncap framerate on supported platforms. This makes performance comparison
	# easier on high-end machines that easily reach the monitor's refresh rate.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _process(delta: float) -> void:
	counter += delta
	# Hide FPS label until it's initially updated by the engine (this can take up to 1 second).
	fps_label.visible = counter >= 1.0
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	# Color FPS counter depending on framerate.
	# The Gradient resource is stored as metadata within the FPSLabel node (accessible in the inspector).
	fps_label.modulate = fps_label.get_meta("gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))


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

# Video settings.

func _on_ui_scale_option_button_item_selected(index: int) -> void:
	# For changing the UI, we take the viewport size, which we set in the project settings.
	var new_size := viewport_start_size
	if index == 0: # Smaller (66%)
		new_size *= 1.5
	elif index == 1: # Small (80%)
		new_size *= 1.25
	elif index == 2: # Medium (100%) (default)
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
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
		%FSRSharpnessLabel.visible = false
		%FSRSharpnessSlider.visible = false
	elif index == 1: # FSR 1.0 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
		%FSRSharpnessLabel.visible = true
		%FSRSharpnessSlider.visible = true
	elif index == 2: # FSR 2.2 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
		%FSRSharpnessLabel.visible = true
		%FSRSharpnessSlider.visible = true


func _on_fsr_sharpness_slider_value_changed(value: float) -> void:
	# Lower FSR sharpness values result in a sharper image.
	# Invert the slider so that higher values result in a sharper image,
	# which is generally expected from users.
	get_viewport().fsr_sharpness = 2.0 - value


func _on_vsync_option_button_item_selected(index: int) -> void:
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible at the cost of
	# higher input latency and stuttering when the framerate target is not met.
	# Adaptive V-Sync automatically disables V-Sync when the framerate target is not met, and enables
	# V-Sync otherwise. This prevents suttering and reduces input latency when the framerate target
	# is not met, at the cost of visible tearing.
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_limit_fps_slider_value_changed(value: float):
	# The maximum number of frames per second that can be rendered.
	# A value of 0 means "no limit".
	Engine.max_fps = value


func _on_msaa_option_button_item_selected(index: int) -> void:
	# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
	# transparent (alpha scissor) textures.
	if index == 0: # Disabled (default)
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X


func _on_taa_option_button_item_selected(index: int) -> void:
	# Temporal antialiasing. Smooths out everything including specular aliasing, but can introduce
	# ghosting artifacts and blurring in motion. Moderate performance cost.
	get_viewport().use_taa = index == 1


func _on_fxaa_option_button_item_selected(index: int) -> void:
	# Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha scissor edges),
	# but blurs the whole scene rendering slightly.
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA


func _on_fullscreen_option_button_item_selected(index: int) -> void:
	# To change between winow, fullscreen and other window modes,
	# set the root mode to one of the options of Window.MODE_*.
	# Other modes are maximized and minimized.
	if index == 0: # Disabled (default)
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1: # Fullscreen
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)
	elif index == 2: # Exclusive Fullscreen
		get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)


func _on_fov_slider_value_changed(value: float) -> void:
	camera.fov = value

# Quality settings.

func _on_shadow_size_option_button_item_selected(index):
	if index == 0: # Minimum
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		# Adjust shadow bias according to shadow resolution.
		# Higher resultions can use a lower bias without suffering from shadow acne.
		directional_light.shadow_bias = 0.06

		# Disable positional (omni/spot) light shadows entirely to further improve performance.
		# These often don't contribute as much to a scene compared to directional light shadows.
		get_viewport().positional_shadow_atlas_size = 0
	if index == 1: # Very Low
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		directional_light.shadow_bias = 0.04
		get_viewport().positional_shadow_atlas_size = 1024
	if index == 2: # Low
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		directional_light.shadow_bias = 0.03
		get_viewport().positional_shadow_atlas_size = 2048
	if index == 3: # Medium (default)
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		directional_light.shadow_bias = 0.02
		get_viewport().positional_shadow_atlas_size = 4096
	if index == 4: # High
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		directional_light.shadow_bias = 0.01
		get_viewport().positional_shadow_atlas_size = 8192
	if index == 5: # Ultra
		RenderingServer.directional_shadow_atlas_set_size(16384, true)
		directional_light.shadow_bias = 0.005
		get_viewport().positional_shadow_atlas_size = 16384


func _on_shadow_filter_option_button_item_selected(index):
	if index == 0: # Very Low
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	if index == 1: # Low
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	if index == 2: # Medium (default)
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	if index == 3: # High
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	if index == 4: # Very High
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	if index == 5: # Ultra
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


func _on_mesh_lod_option_button_item_selected(index):
	if index == 0: # Very Low
		get_viewport().mesh_lod_threshold = 8.0
	if index == 0: # Low
		get_viewport().mesh_lod_threshold = 4.0
	if index == 1: # Medium
		get_viewport().mesh_lod_threshold = 2.0
	if index == 2: # High (default)
		get_viewport().mesh_lod_threshold = 1.0
	if index == 3: # Ultra
		# Always use highest LODs to avoid any form of pop-in.
		get_viewport().mesh_lod_threshold = 0.0

# Effect settings.

func _on_ss_reflections_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	if index == 0: # Disabled (default)
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
	# then be sure to run this function again to make the setting effective.
	if index == 0: # Disabled (default)
		world_environment.environment.ssao_enabled = false
	if index == 1: # Very Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 2: # Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
	if index == 3: # Medium
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if index == 4: # High
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	if index == 5: # Ultra
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.5, 2, 50, 300)


func _on_ssil_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	if index == 0: # Disabled (default)
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
	if index == 5: # Ultra
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)


func _on_sdfgi_option_button_item_selected(index: int) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	if index == 0: # Disabled (default)
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
	# then be sure to run this function again to make the setting effective.
	if index == 0: # Disabled (default)
		world_environment.environment.glow_enabled = false
	if index == 1: # Low
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(false)
	if index == 2: # High
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(true)


func _on_volumetric_fog_option_button_item_selected(index: int) -> void:
	if index == 0: # Disabled (default)
		world_environment.environment.volumetric_fog_enabled = false
	if index == 1: # Low
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(false)
	if index == 2: # High
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(true)

# Adjustment settings.

func _on_brightness_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	# The slider value is clamped between 0.5 and 4.
	world_environment.environment.set_adjustment_brightness(value)


func _on_contrast_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	# The slider value is clamped between 0.5 and 4.
	world_environment.environment.set_adjustment_contrast(value)


func _on_saturation_slider_value_changed(value: float) -> void:
	# This is a setting that is attached to the environment.
	# If your game requires you to change the environment,
	# then be sure to run this function again to make the setting effective.
	# The slider value is clamped between 0.5 and 10.
	world_environment.environment.set_adjustment_saturation(value)

# Quality presets.

func _on_very_low_preset_pressed() -> void:
	%TAAOptionButton.selected = 0
	%MSAAOptionButton.selected = 0
	%FXAAOptionButton.selected = 0
	%ShadowSizeOptionButton.selected = 0
	%ShadowFilterOptionButton.selected = 0
	%MeshLODOptionButton.selected = 0
	%SDFGIOptionButton.selected = 0
	%GlowOptionButton.selected = 0
	%SSAOOptionButton.selected = 0
	%SSReflectionsOptionButton.selected = 0
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 0
	update_preset()

func _on_low_preset_pressed() -> void:
	%TAAOptionButton.selected = 0
	%MSAAOptionButton.selected = 0
	%FXAAOptionButton.selected = 1
	%ShadowSizeOptionButton.selected = 1
	%ShadowFilterOptionButton.selected = 1
	%MeshLODOptionButton.selected = 1
	%SDFGIOptionButton.selected = 0
	%GlowOptionButton.selected = 0
	%SSAOOptionButton.selected = 0
	%SSReflectionsOptionButton.selected = 0
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 0
	update_preset()


func _on_medium_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 0
	%FXAAOptionButton.selected = 0
	%ShadowSizeOptionButton.selected = 2
	%ShadowFilterOptionButton.selected = 2
	%MeshLODOptionButton.selected = 1
	%SDFGIOptionButton.selected = 1
	%GlowOptionButton.selected = 1
	%SSAOOptionButton.selected = 1
	%SSReflectionsOptionButton.selected = 1
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 1
	update_preset()


func _on_high_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 0
	%FXAAOptionButton.selected = 0
	%ShadowSizeOptionButton.selected = 3
	%ShadowFilterOptionButton.selected = 3
	%MeshLODOptionButton.selected = 2
	%SDFGIOptionButton.selected = 1
	%GlowOptionButton.selected = 2
	%SSAOOptionButton.selected = 2
	%SSReflectionsOptionButton.selected = 2
	%SSILOptionButton.selected = 2
	%VolumetricFogOptionButton.selected = 2
	update_preset()


func _on_ultra_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 1
	%FXAAOptionButton.selected = 0
	%ShadowSizeOptionButton.selected = 4
	%ShadowFilterOptionButton.selected = 4
	%MeshLODOptionButton.selected = 3
	%SDFGIOptionButton.selected = 2
	%GlowOptionButton.selected = 2
	%SSAOOptionButton.selected = 3
	%SSReflectionsOptionButton.selected = 3
	%SSILOptionButton.selected = 3
	%VolumetricFogOptionButton.selected = 2
	update_preset()


func update_preset() -> void:
	# Simulate options being manually selected to run their respective update code.
	%TAAOptionButton.item_selected.emit(%TAAOptionButton.selected)
	%MSAAOptionButton.item_selected.emit(%MSAAOptionButton.selected)
	%FXAAOptionButton.item_selected.emit(%FXAAOptionButton.selected)
	%ShadowSizeOptionButton.item_selected.emit(%ShadowSizeOptionButton.selected)
	%ShadowFilterOptionButton.item_selected.emit(%ShadowFilterOptionButton.selected)
	%MeshLODOptionButton.item_selected.emit(%MeshLODOptionButton.selected)
	%SDFGIOptionButton.item_selected.emit(%SDFGIOptionButton.selected)
	%GlowOptionButton.item_selected.emit(%GlowOptionButton.selected)
	%SSAOOptionButton.item_selected.emit(%SSAOOptionButton.selected)
	%SSReflectionsOptionButton.item_selected.emit(%SSReflectionsOptionButton.selected)
	%SSILOptionButton.item_selected.emit(%SSILOptionButton.selected)
	%VolumetricFogOptionButton.item_selected.emit(%VolumetricFogOptionButton.selected)
