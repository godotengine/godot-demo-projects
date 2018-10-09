extends Control

onready var itemList = get_node("ItemList")

func _process(delta):
	var speakerMode = "Stereo"

	if (AudioServer.get_speaker_mode() == AudioServer.SPEAKER_SURROUND_51):
		speakerMode = "Surround 5.1"
	elif (AudioServer.get_speaker_mode() == AudioServer.SPEAKER_SURROUND_71):
		speakerMode = "Surround 7.1"

	$Device.text = "Current Device: " + AudioServer.get_device() + "\n"
	$Device.text+= "Speaker Mode: " + speakerMode

func _ready():
	var list = AudioServer.get_device_list()
	for item in list:
		itemList.add_item(item)

	var device = AudioServer.get_device()
	var i = 0
	while (i < itemList.get_item_count()):
		if (device == itemList.get_item_text(i)):
			itemList.select(i)
			break
		i+= 1

func _on_Button_button_down():
	var array = itemList.get_selected_items()
	for item in array:
		var device = itemList.get_item_text(item)
		AudioServer.set_device(device)

func _on_Play_Audio_button_down():
	if ($AudioStreamPlayer.playing):
		$AudioStreamPlayer.stop()
		$PlayAudio.text = "Play Audio"
	else:
		$AudioStreamPlayer.play()
		$PlayAudio.text = "Stop Audio"
