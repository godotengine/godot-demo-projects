# For more information on localization,
# search Godot's online documentation "Internationalization", or visit
# https://docs.godotengine.org/en/latest/tutorials/i18n/index.html

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


func _on_russian_pressed() -> void:
	TranslationServer.set_locale("ru")
	_print_intro()


func _on_play_audio_pressed() -> void:
	$Audio.play()


func _print_intro() -> void:
	print_rich("\n[b]Language:[/b] %s (%s)" % [TranslationServer.get_locale_name(TranslationServer.get_locale()), TranslationServer.get_locale()])

	# In CSV translation, use the appropriate key in the Object.tr() function to fetch
	# the corresponding translation.
	# This is the same for scene nodes containing user-facing texts to be translated.
	print(tr("KEY_INTRO"))

	# CSV does not support plural translations. If you need pluralization, you must use PO instead.


func _on_go_to_po_translation_demo_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://translation_demo_po.tscn"))
