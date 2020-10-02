extends Control

func _on_english_pressed():
	TranslationServer.set_locale("en")


func _on_spanish_pressed():
	TranslationServer.set_locale("es")


func _on_japanese_pressed():
	TranslationServer.set_locale("ja")


func _on_play_pressed():
	$Audio.play()
