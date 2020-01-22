extends Control

onready var itemList = get_node("ItemList")


func _ready():
	for item in AudioServer.get_device_list():
		itemList.add_item(item)
	
	var device = AudioServer.get_device()
	for i in range(itemList.get_item_count()):
		if device == itemList.get_item_text(i):
			itemList.select(i)
			break


func _process(_delta):
	var speakerMode = "Stereo"
	
	if AudioServer.get_speaker_mode() == AudioServer.SPEAKER_SURROUND_31:
		speakerMode = "Surround 3.1"
	elif AudioServer.get_speaker_mode() == AudioServer.SPEAKER_SURROUND_51:
		speakerMode = "Surround 5.1"
	elif AudioServer.get_speaker_mode() == AudioServer.SPEAKER_SURROUND_71:
		speakerMode = "Surround 7.1"
	
	$DeviceInfo.text = "Current Device: " + AudioServer.get_device() + "\n"
	$DeviceInfo.text += "Speaker Mode: " + speakerMode


func _on_Button_button_down():
	for item in itemList.get_selected_items():
		var device = itemList.get_item_text(item)
		AudioServer.set_device(device)


func _on_Play_Audio_button_down():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
		$PlayAudio.text = "Play Audio"
	else:
		$AudioStreamPlayer.play()
		$PlayAudio.text = "Stop Audio"
