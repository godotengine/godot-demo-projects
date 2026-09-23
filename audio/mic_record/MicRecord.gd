extends Control

var effect: AudioEffectRecord
var recording: AudioStreamWAV


func _ready() -> void:
	var idx := AudioServer.get_bus_index(&"Record")
	effect = AudioServer.get_bus_effect(idx, 0)

	# The format is the one property of the recording that can actually be chosen:
	# AudioEffectRecord encodes the captured samples into it when the recording ends.
	$FormatOptionButton.selected = effect.format

	# The mix rate and the channel count are decided by the audio server, not by us.
	# Recordings come back at AudioServer.get_mix_rate() and are always stereo, so
	# these two controls report what will happen rather than asking for it.
	_show_mix_rate(int(AudioServer.get_mix_rate()))
	$MixRateOptionButton.disabled = true
	$MixRateOptionButton.tooltip_text = "Recordings use the audio server's mix rate."
	$StereoCheckButton.button_pressed = true
	$StereoCheckButton.disabled = true
	$StereoCheckButton.tooltip_text = "AudioEffectRecord always records in stereo."


## Selects the item matching the server's mix rate, adding it if the list has no such entry.
func _show_mix_rate(hz: int) -> void:
	for i in $MixRateOptionButton.item_count:
		if $MixRateOptionButton.get_item_text(i).begins_with(str(hz)):
			$MixRateOptionButton.selected = i
			return
	$MixRateOptionButton.add_item("%d Hz" % hz)
	$MixRateOptionButton.selected = $MixRateOptionButton.item_count - 1


func _on_record_button_pressed() -> void:
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		$FormatOptionButton.disabled = false
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		# Changing the format mid-recording would apply to the samples already captured.
		$FormatOptionButton.disabled = true
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."


func _on_play_button_pressed() -> void:
	print_rich("\n[b]Playing recording:[/b] %s" % recording)
	print_rich("[b]Format:[/b] %s" % ("8-bit uncompressed" if recording.format == 0 else "16-bit uncompressed" if recording.format == 1 else "IMA ADPCM compressed"))
	print_rich("[b]Mix rate:[/b] %s Hz" % recording.mix_rate)
	print_rich("[b]Stereo:[/b] %s" % ("Yes" if recording.stereo else "No"))
	var data := recording.get_data()
	print_rich("[b]Size:[/b] %s bytes" % data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()


func _on_play_music_pressed() -> void:
	if $AudioStreamPlayer2.playing:
		$AudioStreamPlayer2.stop()
		$PlayMusic.text = "Play Music"
	else:
		$AudioStreamPlayer2.play()
		$PlayMusic.text = "Stop Music"


func _on_save_button_pressed() -> void:
	var save_path: String = $SaveButton/Filename.text
	recording.save_to_wav(save_path)
	$Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]


func _on_format_option_button_item_selected(index: int) -> void:
	# Applies to the next recording: the effect encodes the samples when recording stops.
	effect.format = index as AudioStreamWAV.Format


func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))
