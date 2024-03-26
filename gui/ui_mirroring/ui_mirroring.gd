extends Control

func _ready():
	$Label.text = TranslationServer.get_locale()

func _on_Button_pressed():
	if TranslationServer.get_locale() != "ar":
		TranslationServer.set_locale("ar")
	else:
		TranslationServer.set_locale("en")
	$Label.text = TranslationServer.get_locale()
