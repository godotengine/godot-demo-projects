extends Control

const HDR_SETTINGS_FILE = "user://hdr_settings.cfg"
const HDR_SETTINGS_SECTION = "HDR"


var _auto_adjust_reference: bool = true
var _auto_adjust_max: bool = true


func _on_visibility_changed() -> void:
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _ready() -> void:
	var window: Window = get_window()
	var window_id = window.get_window_id()
	var hdr_settings: ConfigFile = ConfigFile.new()
	if hdr_settings.load(HDR_SETTINGS_FILE) == OK:
		window.hdr_output_requested = hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_requested", window.hdr_output_requested)
		if supports_manual_reference_luminance():
			DisplayServer.window_set_hdr_output_reference_luminance(hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_reference_luminance", DisplayServer.window_get_hdr_output_reference_luminance(window_id)), window_id)
		if supports_manual_max_luminance():
			DisplayServer.window_set_hdr_output_max_luminance(hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_max_luminance", DisplayServer.window_get_hdr_output_max_luminance(window_id)), window_id)
	
	_auto_adjust_reference = DisplayServer.window_get_hdr_output_reference_luminance(window_id) < 0
	_auto_adjust_max = DisplayServer.window_get_hdr_output_max_luminance(window_id) < 0
	
	%BrightnessDisplay.visible = supports_manual_reference_luminance()
	%BrightnessAdjustment.visible = supports_manual_reference_luminance()
	%MaxLumDisplay.visible = supports_manual_max_luminance()
	%MaxLumAdjustment.visible = supports_manual_max_luminance()


func save_settings() -> void:
	var window: Window = get_window()
	var window_id = window.get_window_id()
	var hdr_settings: ConfigFile = ConfigFile.new()
	hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_requested", window.hdr_output_requested)
	if window.hdr_output_requested:
		hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_reference_luminance", DisplayServer.window_get_hdr_output_reference_luminance(window_id))
		hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_max_luminance", DisplayServer.window_get_hdr_output_max_luminance(window_id))
	hdr_settings.save(HDR_SETTINGS_FILE)


func erase_settings() -> void:
	var hdr_settings: ConfigFile = ConfigFile.new()
	if hdr_settings.load(HDR_SETTINGS_FILE) == OK:
		hdr_settings.erase_section(HDR_SETTINGS_SECTION)
		hdr_settings.save(HDR_SETTINGS_FILE)


func supports_manual_reference_luminance() -> bool:
	if DisplayServer.get_name() == &"Windows":
		return true
	else:
		return false


func supports_manual_max_luminance() -> bool:
	if DisplayServer.get_name() == &"Windows":
		return true
	else:
		return false


func _process(_delta: float) -> void:
	var window_id = get_window().get_window_id()
	var hdr_supported := DisplayServer.window_is_hdr_output_supported(window_id)
	%HDRCheckButton.disabled = !hdr_supported

	var hdr_output_enabled: bool = DisplayServer.window_is_hdr_output_enabled(window_id)
	if %HDRCheckButton.button_pressed != hdr_output_enabled:
		%HDRCheckButton.button_pressed = hdr_output_enabled
	%HDROptions.visible = hdr_output_enabled && hdr_supported
	
	%BrightnessSlider.max_value = DisplayServer.window_get_hdr_output_current_max_luminance()
	%BrightnessSlider.value = DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)
	%BrightnessLabel.text = "%0.0f" % DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)
	
	$%MaxLumSlider.min_value = DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)
	%MaxLumSlider.value = DisplayServer.window_get_hdr_output_current_max_luminance()
	%MaxLumLabel.text = "%0.0f" % DisplayServer.window_get_hdr_output_current_max_luminance()
	
	%ResetBrightness.disabled = DisplayServer.window_get_hdr_output_reference_luminance(window_id) < 0
	%ResetMaxLum.disabled = DisplayServer.window_get_hdr_output_max_luminance(window_id) < 0


func _on_hdr_check_button_toggled(toggled_on: bool) -> void:
	# Request HDR output to the display.
	if !%HDRCheckButton.disabled:
		get_window().hdr_output_requested = toggled_on


func _on_brightness_slider_value_changed(value: float) -> void:
	if !_auto_adjust_reference:
		var window_id = get_window().get_window_id()
		DisplayServer.window_set_hdr_output_reference_luminance(value, window_id)


func _on_max_lum_slider_value_changed(value: float) -> void:
	if !_auto_adjust_max:
		var window_id = get_window().get_window_id()
		DisplayServer.window_set_hdr_output_max_luminance(value, window_id)


func _on_reset_brightness_pressed() -> void:
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_hdr_output_reference_luminance(-1, window_id)
	_auto_adjust_reference = true


func _on_reset_max_lum_pressed() -> void:
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_hdr_output_max_luminance(-1, window_id)
	_auto_adjust_max = true


func _on_brightness_slider_drag_started() -> void:
	_auto_adjust_reference = false


func _on_max_lum_slider_drag_started() -> void:
	_auto_adjust_max = false
