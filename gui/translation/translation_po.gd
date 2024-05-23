# For more information on translation using PO files,
# search Godot's online documentation "Localization using gettext", or visit
# https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html

extends Panel

func _ready() -> void:
	_print_intro()


func _on_english_pressed() -> void:
	TranslationServer.set_locale("en")
	_print_intro()


func _on_spanish_pressed() -> void:
	TranslationServer.set_locale("es")
	_print_intro()


func _on_japanese_pressed() -> void:
	TranslationServer.set_locale("ja")
	_print_intro()


func _on_play_audio_pressed() -> void:
	$Audio.play()


func _print_intro() -> void:
	print_rich("\n[b]Language:[/b] %s (%s)" % [TranslationServer.get_locale_name(TranslationServer.get_locale()), TranslationServer.get_locale()])

	# In PO translation, you would use source string as the 'key' for the Object.tr() function.
	# This is the same for scene nodes containing user-facing texts to be translated.
	print(tr("Hello, this is a translation demo project."))

	# PO plural translation example.
	# The difference with CSV is that you must add the "plural_message" argument, because PO files
	# expect the data (else undefine behaviour might occur).
	var days_passed := randi_range(1, 3)
	print(tr_n("One day ago.", "{days} days ago.", days_passed).format({ days = days_passed }))


func _on_go_to_csv_translation_demo_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://translation_demo_csv.tscn"))
