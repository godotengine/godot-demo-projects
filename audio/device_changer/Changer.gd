extends Control

@onready var item_list: ItemList = $ItemList

func _ready() -> void:
	for item in AudioServer.get_output_device_list():
		item_list.add_item(item)

	var device := AudioServer.get_output_device()
	for i in item_list.get_item_count():
		if device == item_list.get_item_text(i):
			item_list.select(i)
			break


func _process(_delta: float) -> void:
	var speaker_mode_text := "Stereo"
	var speaker_mode := AudioServer.get_speaker_mode()

	if speaker_mode == AudioServer.SPEAKER_SURROUND_31:
		speaker_mode_text = "Surround 3.1"
	elif speaker_mode == AudioServer.SPEAKER_SURROUND_51:
		speaker_mode_text = "Surround 5.1"
	elif speaker_mode == AudioServer.SPEAKER_SURROUND_71:
		speaker_mode_text = "Surround 7.1"

	$DeviceInfo.text = "Current Device: " + AudioServer.get_output_device() + "\n"
	$DeviceInfo.text += "Speaker Mode: " + speaker_mode_text


func _on_Button_button_down() -> void:
	for item in item_list.get_selected_items():
		var device := item_list.get_item_text(item)
		AudioServer.set_output_device(device)


func _on_Play_Audio_button_down() -> void:
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
		$PlayAudio.text = "Play Audio"
	else:
		$AudioStreamPlayer.play()
		$PlayAudio.text = "Stop Audio"
