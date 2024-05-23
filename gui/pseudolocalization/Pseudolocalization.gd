extends Control

func _ready() -> void:
	$Main/Pseudolocalization_options/accents.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/replace_with_accents")
	$Main/Pseudolocalization_options/toggle.button_pressed = TranslationServer.pseudolocalization_enabled
	$Main/Pseudolocalization_options/fakebidi.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/fake_bidi")
	$Main/Pseudolocalization_options/doublevowels.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/double_vowels")
	$Main/Pseudolocalization_options/override.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/override")
	$Main/Pseudolocalization_options/skipplaceholders.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/skip_placeholders")
	$Main/Pseudolocalization_options/prefix/TextEdit.text = ProjectSettings.get_setting("internationalization/pseudolocalization/prefix")
	$Main/Pseudolocalization_options/suffix/TextEdit.text = ProjectSettings.get_setting("internationalization/pseudolocalization/suffix")
	$Main/Pseudolocalization_options/exp_ratio/SpinBox.value = float(ProjectSettings.get_setting("internationalization/pseudolocalization/expansion_ratio"))


func _on_accents_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/replace_with_accents", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_toggle_toggled(button_pressed: bool) -> void:
	TranslationServer.pseudolocalization_enabled = button_pressed


func _on_fake_bidi_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/fake_bidi", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_prefix_changed(new_text: String) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/prefix", new_text)
	TranslationServer.reload_pseudolocalization()


func _on_suffix_changed(new_text: String) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/suffix", new_text)
	TranslationServer.reload_pseudolocalization()


func _on_pseudolocalize_pressed() -> void:
	$Main/Pseudolocalizer/Result.text = TranslationServer.pseudolocalize($Main/Pseudolocalizer/Key.text)


func _on_double_vowels_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/double_vowels", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_expansion_ratio_value_changed(value: float) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/expansion_ratio", value)
	TranslationServer.reload_pseudolocalization()


func _on_override_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/override", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_skip_placeholders_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/skip_placeholders", button_pressed)
	TranslationServer.reload_pseudolocalization()
