extends Control

var recording: AudioStreamWAV

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings.
var format := AudioStreamWAV.FORMAT_16_BITS  # This is the default format on recordings.

var audiosamplesize : int = 882
var audiosampleframetextureimage : Image
var audiosampleframetexture : ImageTexture
var totalsamples = 0
var sampleduration = 0.0
var recordingbuffer = null

func _ready() -> void:
	Input.start_microphone()
	var audiosampleframedata_blank : PackedVector2Array = PackedVector2Array()
	audiosampleframedata_blank.resize(audiosamplesize)
	for j in range(audiosamplesize):
		audiosampleframedata_blank.set(j, Vector2(-0.5,0.9) if (j%10)<5 else Vector2(0.6,0.1))
	audiosampleframetextureimage = Image.create_from_data(audiosamplesize, 1, false, Image.FORMAT_RGF, audiosampleframedata_blank.to_byte_array())
	audiosampleframetexture = ImageTexture.create_from_image(audiosampleframetextureimage)
	$MicTexture.material.set_shader_parameter("audiosample", audiosampleframetexture)

func _process(delta):
	sampleduration += delta
	var audiosamples : PackedVector2Array = Input.get_microphone_buffer(audiosamplesize)
	if audiosamples:
		audiosampleframetextureimage.set_data(audiosamplesize, 1, false, Image.FORMAT_RGF, audiosamples.to_byte_array())
		audiosampleframetexture.update(audiosampleframetextureimage)
		totalsamples += len(audiosamples)
		$SampleCount.text = "%.0f samples/sec" % (totalsamples/sampleduration)
		if recordingbuffer != null:
			recordingbuffer.append(audiosamples)


func _on_record_button_pressed() -> void:
	totalsamples = 0
	sampleduration = 0.0
	if recordingbuffer != null:
		#recording = recordeffect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		#recordeffect.set_recording_active(false)
		#recording.set_mix_rate(mix_rate)
		#recording.set_format(format)
		#recording.set_stereo(stereo)
		$RecordButton.text = "Record"
		$Status.text = ""
		recordingbuffer = null
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		recordingbuffer = [ ]
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


func _on_mix_rate_option_button_item_selected(index: int) -> void:
	match index:
		0:
			mix_rate = 11025
		1:
			mix_rate = 16000
		2:
			mix_rate = 22050
		3:
			mix_rate = 32000
		4:
			mix_rate = 44100
		5:
			mix_rate = 48000
	if recording != null:
		recording.set_mix_rate(mix_rate)


func _on_format_option_button_item_selected(index: int) -> void:
	match index:
		0:
			format = AudioStreamWAV.FORMAT_8_BITS
		1:
			format = AudioStreamWAV.FORMAT_16_BITS
		2:
			format = AudioStreamWAV.FORMAT_IMA_ADPCM
	if recording != null:
		recording.set_format(format)


func _on_stereo_check_button_toggled(button_pressed: bool) -> void:
	stereo = button_pressed
	if recording != null:
		recording.set_stereo(stereo)


func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))
