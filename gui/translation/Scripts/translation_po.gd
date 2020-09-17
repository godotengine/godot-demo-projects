# For more information on translation using PO files,
# search Godot's online documentation "Localization using gettext", or visit
# https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html

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


func _on_play_pressed():
	$Audio.play()


func _print_intro():
	# In PO translation, you would use source string as the 'key' for the Object.tr() function.
	# This is the same for scene nodes containing user-facing texts to be translated.
	print(tr("Hello, this is a translation demo project."))
	
	# PO plural translation example.
	# The difference with CSV is that you must add the "plural_message" argument, because PO files
	# expect the data (else undefine behaviour might occur).
	var days_passed = randi() % 100
	print(tr_n(days_passed, "One day ago.", "%d days ago.") % days_passed)
