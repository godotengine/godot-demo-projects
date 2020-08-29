# For more information on localization,
# search Godot's online documentation "Internationalization", or visit
# https://docs.godotengine.org/en/latest/tutorials/i18n/index.html

extends Panel

func _ready():
	_print_intro()

func _on_english_pressed():
	TranslationServer.set_locale("en")
	_print_intro()


func _on_spanish_pressed():
	TranslationServer.set_locale("es")
	_print_intro()


func _on_japanese_pressed():
	TranslationServer.set_locale("ja")
	_print_intro()


func _on_russian_pressed():
	TranslationServer.set_locale("ru")
	_print_intro()


func _on_play_pressed():
	$Audio.play()


func _print_intro():
	# In CSV translation, use the appropriate key in the Object.tr() function to fetch
	# the corresponding translation.
	# This is the same for scene nodes containing user-facing texts to be translated.
	print(tr("KEY_INTRO"))
	
	# CSV plural translation example.
	var days_passed = randi() % 100
	print(tr_n(days_passed, "KEY_DAYS") % days_passed)

