extends Control

func _ready() -> void:
	_set_text_in_label()


func _on_english_pressed():
	TranslationServer.set_locale("en")


func _on_spanish_pressed():
	TranslationServer.set_locale("es")


func _on_japanese_pressed():
	TranslationServer.set_locale("ja")


func _on_play_pressed():
	$Audio.play()


func _set_text_in_label():
	# Use tr(translation_key) to get the desired string in the correct language.
	var message := "This text is being translated through script: \n"
	message += tr("KEY_TEXT")
	$TextLabel.text = message


func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_set_text_in_label()
