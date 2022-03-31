extends Control

var effect  # See AudioEffect in docs
var recording  # See AudioStreamSample in docs

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits


func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)


func _on_RecordButton_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		recording.set_mix_rate(mix_rate)
		recording.set_format(format)
		recording.set_stereo(stereo)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."


func _on_PlayButton_pressed():
	print("Recording: %s" % recording)
	print("Format: %s" % recording.format)
	print("Mix rate: %s" % recording.mix_rate)
	print("Stereo: %s" % recording.stereo)
	var data = recording.get_data()
	print("Size: %s" % data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()


func _on_Play_Music_pressed():
	if $AudioStreamPlayer2.playing:
		$AudioStreamPlayer2.stop()
		$PlayMusic.text = "Play Music"
	else:
		$AudioStreamPlayer2.play()
		$PlayMusic.text = "Stop Music"


func _on_SaveButton_pressed():
	var save_path = $SaveButton/Filename.text
	recording.save_to_wav(save_path)
	$Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]


func _on_mix_rate_option_button_item_selected(index: int) -> void:
	if index == 0:
		mix_rate = 11025
	elif index == 1:
		mix_rate = 16000
	elif index == 2:
		mix_rate = 22050
	elif index == 3:
		mix_rate = 32000
	elif index == 4:
		mix_rate = 44100
	elif index == 5:
		mix_rate = 48000
	
	if recording != null:
		recording.set_mix_rate(mix_rate)


func _on_format_option_button_item_selected(index: int) -> void:
	if index == 0:
		format = AudioStreamSample.FORMAT_8_BITS
	elif index == 1:
		format = AudioStreamSample.FORMAT_16_BITS
	elif index == 2:
		format = AudioStreamSample.FORMAT_IMA_ADPCM
	
	if recording != null:
		recording.set_format(format)


func _on_stereo_check_button_toggled(button_pressed: bool) -> void:
	stereo = button_pressed
	
	if recording != null:
		recording.set_stereo(stereo)
