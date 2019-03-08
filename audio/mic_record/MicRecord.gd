extends Node

var effect
var recording

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)

func _on_RecordButton_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Recording..."

func _on_PlayButton_pressed():
	print(recording)
	print(recording.format)
	print(recording.mix_rate)
	print(recording.stereo)
	var data = recording.get_data()
	print(data)
	print(data.size())
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
	$Status.text = "Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]
