extends Control


func _on_toggle_music_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$SoundEffects/Music.play()
	else:
		$SoundEffects/Music.stop()


func _on_ding_button_pressed() -> void:
	$SoundEffects/Ding.play()


func _on_glass_button_pressed() -> void:
	$SoundEffects/Glass.play()


func _on_meow_button_pressed() -> void:
	$SoundEffects/Meow.play()


func _on_beeps_button_pressed() -> void:
	$SoundEffects/Beeps.play()


func _on_trombone_button_pressed() -> void:
	$SoundEffects/Trombone.play()


func _on_static_button_pressed() -> void:
	$SoundEffects/Static.play()


func _on_whistle_button_pressed() -> void:
	$SoundEffects/Whistle.play()


func _on_toggle_amplify_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 0, button_pressed)


func _on_toggle_band_limiter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 1, button_pressed)


func _on_toggle_band_pass_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 2, button_pressed)


func _on_toggle_chorus_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 3, button_pressed)


func _on_toggle_compressor_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 4, button_pressed)


func _on_toggle_delay_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 5, button_pressed)


func _on_toggle_distortion_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 6, button_pressed)


func _on_toggle_eq_6_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 7, button_pressed)


func _on_toggle_eq_10_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 8, button_pressed)


func _on_toggle_eq_21_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 9, button_pressed)


func _on_toggle_high_pass_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 10, button_pressed)


func _on_toggle_low_shelf_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 11, button_pressed)


func _on_toggle_notch_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 12, button_pressed)


func _on_toggle_panner_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 13, button_pressed)


func _on_toggle_phaser_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 14, button_pressed)


func _on_toggle_pitch_shift_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 15, button_pressed)


func _on_toggle_reverb_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 16, button_pressed)


func _on_toggle_stereo_enhance_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 17, button_pressed)
