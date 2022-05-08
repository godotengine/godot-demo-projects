extends Control

func _ready():
	$Main/Pseudolocalization_options/accents.button_pressed = ProjectSettings.get("internationalization/pseudolocalization/replace_with_accents")
	$Main/Pseudolocalization_options/toggle.button_pressed = TranslationServer.pseudolocalization_enabled
	$Main/Pseudolocalization_options/fakebidi.button_pressed = ProjectSettings.get("internationalization/pseudolocalization/fake_bidi")
	$Main/Pseudolocalization_options/doublevowels.button_pressed = ProjectSettings.get("internationalization/pseudolocalization/double_vowels")
	$Main/Pseudolocalization_options/override.button_pressed = ProjectSettings.get("internationalization/pseudolocalization/override")
	$Main/Pseudolocalization_options/skipplaceholders.button_pressed = ProjectSettings.get("internationalization/pseudolocalization/skip_placeholders")
	$Main/Pseudolocalization_options/prefix/TextEdit.text = ProjectSettings.get("internationalization/pseudolocalization/prefix")
	$Main/Pseudolocalization_options/suffix/TextEdit.text = ProjectSettings.get("internationalization/pseudolocalization/suffix")
	$Main/Pseudolocalization_options/exp_ratio/TextEdit.text = str(ProjectSettings.get("internationalization/pseudolocalization/expansion_ratio"))


func _on_accents_toggled(button_pressed):
	ProjectSettings.set("internationalization/pseudolocalization/replace_with_accents", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_toggle_toggled(button_pressed):
	TranslationServer.pseudolocalization_enabled = button_pressed


func _on_fakebidi_toggled(button_pressed):
	ProjectSettings.set("internationalization/pseudolocalization/fake_bidi", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_prefix_changed():
	ProjectSettings.set("internationalization/pseudolocalization/prefix", $Main/Pseudolocalization_options/prefix/TextEdit.text)
	TranslationServer.reload_pseudolocalization()


func _on_suffix_changed():
	ProjectSettings.set("internationalization/pseudolocalization/suffix", $Main/Pseudolocalization_options/suffix/TextEdit.text)
	TranslationServer.reload_pseudolocalization()


func _on_Pseudolocalize_pressed():
	$Main/Pseudolocalizer/Result.text = TranslationServer.pseudolocalize($Main/Pseudolocalizer/Key.text)


func _on_doublevowels_toggled(button_pressed):
	ProjectSettings.set("internationalization/pseudolocalization/double_vowels", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_expansion_ratio_text_changed():
	var ratio = ($Main/Pseudolocalization_options/exp_ratio/TextEdit.text).to_float()
	if ratio > 1:
		ratio = 1
		$Main/Pseudolocalization_options/exp_ratio/TextEdit.text = str(ratio)
	if ratio < 0:
		ratio = 0
		$Main/Pseudolocalization_options/exp_ratio/TextEdit.text = str(ratio)
	ProjectSettings.set("internationalization/pseudolocalization/expansion_ratio", ratio)
	TranslationServer.reload_pseudolocalization()


func _on_override_toggled(button_pressed):
	ProjectSettings.set("internationalization/pseudolocalization/override", button_pressed)
	TranslationServer.reload_pseudolocalization()


func _on_skipplaceholders_toggled(button_pressed):
	ProjectSettings.set("internationalization/pseudolocalization/skip_placeholders", button_pressed)
	TranslationServer.reload_pseudolocalization()
