extends Control

## The utterance ID to use for text to speech.
var id := 0

var ut_map := {}
var vs: Array[Dictionary]

func _ready() -> void:
	# Get voice data.
	vs = DisplayServer.tts_get_voices()
	var root: TreeItem = $Tree.create_item()
	$Tree.set_hide_root(true)
	$Tree.set_column_title(0, "Name")
	$Tree.set_column_title(1, "Language")
	$Tree.set_column_titles_visible(true)
	for v in vs:
		var child: TreeItem = $Tree.create_item(root)
		child.set_text(0, v["name"])
		child.set_metadata(0, v["id"])
		child.set_text(1, v["language"])
	$Log.text += "%d voices available.\n" % [vs.size()]
	$Log.text += "=======\n"

	# Ensure the first voice added to the list is preselected.
	$Tree.get_root().get_child(0).select(0)

	# Add callbacks.
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_STARTED, _on_utterance_start)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _on_utterance_end)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_CANCELED, _on_utterance_error)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_BOUNDARY, _on_utterance_boundary)


func _process(_delta: float) -> void:
	$ButtonPause.button_pressed = DisplayServer.tts_is_paused()
	if DisplayServer.tts_is_speaking():
		$ColorRect.color = Color(0.9, 0.3, 0.1)
	else:
		$ColorRect.color = Color(1, 1, 1)


func _on_utterance_boundary(pos: int, ut_id: int) -> void:
	$RichTextLabel.text = "[bgcolor=yellow][color=black]" + ut_map[ut_id].substr(0, pos) + "[/color][/bgcolor]" + ut_map[ut_id].substr(pos, -1)


func _on_utterance_start(ut_id: int) -> void:
	$Log.text += "Utterance %d started.\n" % [ut_id]


func _on_utterance_end(ut_id: int) -> void:
	$RichTextLabel.text = "[bgcolor=yellow][color=black]" + ut_map[ut_id] + "[/color][/bgcolor]"
	$Log.text += "Utterance %d ended.\n" % [ut_id]
	ut_map.erase(ut_id)


func _on_utterance_error(ut_id: int) -> void:
	$RichTextLabel.text = ""
	$Log.text += "Utterance %d canceled/failed.\n" % [ut_id]
	ut_map.erase(ut_id)


func _on_button_stop_pressed() -> void:
	DisplayServer.tts_stop()


func _on_button_pause_pressed() -> void:
	if $ButtonPause.pressed:
		DisplayServer.tts_pause()
	else:
		DisplayServer.tts_resume()


func _on_button_speak_pressed() -> void:
	if $Tree.get_selected():
		$Log.text += "Utterance %d queried.\n" % [id]
		ut_map[id] = $Utterance.text
		DisplayServer.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, false)
		id += 1
	else:
		OS.alert("No voice selected.\nSelect a voice in the list, then try using Speak again.")


func _on_button_int_speak_pressed() -> void:
	if $Tree.get_selected():
		$Log.text += "Utterance %d interrupted.\n" % [id]
		ut_map[id] = $Utterance.text
		DisplayServer.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, true)
		id += 1
	else:
		OS.alert("No voice selected.\nSelect a voice in the list, then try using Interrupt again.")


func _on_button_clear_log_pressed() -> void:
	$Log.text = ""


func _on_HSliderRate_value_changed(value: float) -> void:
	$HSliderRate/Value.text = "%.2fx" % value


func _on_HSliderPitch_value_changed(value: float) -> void:
	$HSliderPitch/Value.text = "%.2fx" % value


func _on_HSliderVolume_value_changed(value: float) -> void:
	$HSliderVolume/Value.text = "%d%%" % value


func _on_Button_pressed() -> void:
	var vc: PackedStringArray
	#demo - en
	vc = DisplayServer.tts_get_voices_for_language("en")
	if not vc.is_empty():
		ut_map[id] = "Beware the Jabberwock, my son!"
		ut_map[id + 1] = "The jaws that bite, the claws that catch!"
		DisplayServer.tts_speak("Beware the Jabberwock, my son!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("The jaws that bite, the claws that catch!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2
	#demo - es
	vc = DisplayServer.tts_get_voices_for_language("es")
	if not vc.is_empty():
		ut_map[id] = "¡Cuidado, hijo, con el Fablistanón!"
		ut_map[id + 1] = "¡Con sus dientes y garras, muerde, apresa!"
		DisplayServer.tts_speak("¡Cuidado, hijo, con el Fablistanón!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("¡Con sus dientes y garras, muerde, apresa!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2
	#demo - ru
	vc = DisplayServer.tts_get_voices_for_language("ru")
	if not vc.is_empty():
		ut_map[id] = "О, бойся Бармаглота, сын!"
		ut_map[id + 1] = "Он так свирлеп и дик!"
		DisplayServer.tts_speak("О, бойся Бармаглота, сын!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("Он так свирлеп и дик!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2


func _on_LineEditFilterName_text_changed(_new_text: String) -> void:
	$Tree.clear()
	var root: TreeItem = $Tree.create_item()
	for v in vs:
		if (
				$LineEditFilterName.text.is_empty() or $LineEditFilterName.text.to_lower() in v["name"].to_lower()
		) and (
				$LineEditFilterLang.text.is_empty() or $LineEditFilterLang.text.to_lower() in v["language"].to_lower()
		):
			var child: TreeItem = $Tree.create_item(root)
			child.set_text(0, v["name"])
			child.set_metadata(0, v["id"])
			child.set_text(1, v["language"])
