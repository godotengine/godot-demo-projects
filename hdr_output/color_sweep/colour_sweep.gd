extends Control

var clip_to_max_lum: bool = false


func _process(_delta: float) -> void:
	var window: Window = get_window()
	var window_id = get_window().get_window_id()
	var sm: ShaderMaterial = %ColourSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter("max_value", window.get_output_max_linear_value());
	%SweepMinLabel.text = "%+0.2f (linear %0.5f, %0.0f nits)" % [%MinHSlider.value, pow(2, %MinHSlider.value), pow(2, %MinHSlider.value) * DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)]
	%SweepMaxLabel.text = "%+0.2f (linear %0.5f, %0.0f nits)" % [%MaxHSlider.value, pow(2, %MaxHSlider.value), pow(2, %MaxHSlider.value) * DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)]


func _on_min_h_slider_value_changed(value: float) -> void:
	%MaxHSlider.min_value = value;
	var sm: ShaderMaterial = %ColourSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter("log2_min", value)


func _on_max_h_slider_value_changed(value: float) -> void:
	%MinHSlider.max_value = value;
	var sm: ShaderMaterial = %ColourSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter("log2_max", value)
