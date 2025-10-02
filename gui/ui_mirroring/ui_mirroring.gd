extends Control

func _ready() -> void:
	$Label.text = TranslationServer.get_locale()


func _on_Button_pressed() -> void:
	if TranslationServer.get_locale() != "ar":
		TranslationServer.set_locale("ar")
	else:
		TranslationServer.set_locale("en")

	$Label.text = TranslationServer.get_locale()
