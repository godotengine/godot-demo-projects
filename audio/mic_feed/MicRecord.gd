extends Control

var wav_recording: AudioStreamWAV
var input_mix_rate: int = 44100
var audio_chunk_size_ms: int = 20
var audio_sample_size: int = 882

var total_samples: int = 0
var sample_duration: float = 0.0
var recording_buffer: Variant = null

var audio_sample_image: Image
var audio_sample_texture: ImageTexture
var generator_timestamp: float = 0.0
var generator_freq: float = 0.0

var microphone_feed = null


func _ready() -> void:
	for d in AudioServer.get_input_device_list():
		$OptionInput.add_item(d)
	assert($OptionInput.get_item_text($OptionInput.selected) == "Default")

	for d in AudioServer.get_output_device_list():
		$OptionOutput.add_item(d)
	assert($OptionOutput.get_item_text($OptionOutput.selected) == "Default")

	input_mix_rate = int(AudioServer.get_input_mix_rate())
	print("Input mix rate: ", input_mix_rate)
	print("Output mix rate: ", AudioServer.get_mix_rate())
	print("Project mix rate: ", ProjectSettings.get("audio/driver/mix_rate"))

	if Engine.has_singleton("MicrophoneServer"):
		microphonefeed = Engine.get_singleton("MicrophoneServer").get_feed(0)
	if not microphonefeed:
		$Status.text = "**** Error: requires PR#108773 to work"
		print($Status.text)
		set_process(false)
		$MicrophoneOn.disabled = true

	$InputMixRate.text = "Mix rate: %d" % input_mix_rate
	audio_sample_size = int(audio_chunk_size_ms*input_mix_rate/1000.0)
	var blank_image: PackedVector2Array = PackedVector2Array()
	blank_image.resize(audio_sample_size)
	audio_sample_image = Image.create_from_data(audio_sample_size, 1, false, Image.FORMAT_RGF, blank_image.to_byte_array())
	audio_sample_texture = ImageTexture.create_from_image(audio_sample_image)
	$MicTexture.material.set_shader_parameter(&"audiosample", audio_sample_texture)

func _on_option_input_item_selected(index: int) -> void:
	var inputdevice: String = $OptionInput.get_item_text(index)
	print("Set input device: ", inputdevice)
	AudioServer.set_input_device(inputdevice)

func _on_option_output_item_selected(index: int) -> void:
	var outputdevice: String = $OptionOutput.get_item_text(index)
	print("Set output device: ", outputdevice)
	AudioServer.set_output_device(outputdevice)

func _on_microphone_on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if OS.get_name() == "Android" and not OS.request_permission("android.permission.RECORD_AUDIO"):
			print("Waiting for user response after requesting audio permissions")
			# yuou also need to enabled Record Audio in the android export settings
			@warning_ignore("untyped_declaration")
			var x = await get_tree().on_request_permissions_result
			var permission: String = x[0]
			var granted: bool = x[1]
			assert (permission == "android.permission.RECORD_AUDIO")
			print("Audio permission granted ", granted)

		if not microphonefeed.is_active():
			microphonefeed.set_active(true)
		total_samples = 0
		sample_duration = 0.0
		print("Input buffer length frames: ", microphonefeed.get_buffer_length_frames())
		print("Input buffer length seconds: ", microphonefeed.get_buffer_length_frames()*1.0/input_mix_rate)
	else:
		microphonefeed.set_active(false)

func _on_mic_to_generator_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$AudioGenerator.stream.mix_rate = input_mix_rate
	$AudioGenerator.playing = toggled_on

func _process(delta: float) -> void:
	sample_duration += delta
	while microphonefeed.get_frames_available() >= audio_sample_size:
		var audio_samples: PackedVector2Array = microphonefeed.get_frames(audio_sample_size)
		if audio_samples:
			audio_sample_image.set_data(audio_sample_size, 1, false, Image.FORMAT_RGF, audio_samples.to_byte_array())
			audio_sample_texture.update(audio_sample_image)
			total_samples += 1
			$SampleCount.text = "%.0f samples/sec" % (total_samples*audio_sample_size/sample_duration)
			if recording_buffer != null:
				recording_buffer.append(audio_samples)
			if $MicToGenerator.button_pressed:
				$AudioGenerator.get_stream_playback().push_buffer(audio_samples)
	if generator_freq != 0.0:
		var gplayback: AudioStreamGeneratorPlayback = $AudioGenerator.get_stream_playback()
		var gdt: float = 1.0/$AudioGenerator.stream.mix_rate
		for i in range(gplayback.get_frames_available()):
			var a: float = 0.5*sin(generator_timestamp*generator_freq*TAU)
			gplayback.push_frame(Vector2(a, a))
			generator_timestamp += gdt

func _on_record_button_toggled(toggled_on: bool) -> void:
	total_samples = 0
	sample_duration = 0.0
	if toggled_on:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		recording_buffer = [ ]
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."

	else:
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		var recording_data: PackedByteArray = PackedByteArray()
		var data_size: int = 4*audio_sample_size*len(recording_buffer)
		recording_data.resize(44 + data_size)
		recording_data.encode_u32(0, 0x46464952) # RIFF
		recording_data.encode_u32(4, len(recording_data) - 8)
		recording_data.encode_u32(8, 0x45564157) # WAVE
		recording_data.encode_u32(12, 0x20746D66) # 'fmt '
		recording_data.encode_u32(16, 16)
		recording_data.encode_u16(20, 1)
		recording_data.encode_u16(22, 2)
		recording_data.encode_u32(24, input_mix_rate)
		recording_data.encode_u32(28, input_mix_rate*4) # *16*2/8
		recording_data.encode_u16(32, 4) # 16*2/8
		recording_data.encode_u16(34, 16)
		recording_data.encode_u32(36, 0x61746164) # 'data'
		recording_data.encode_u32(40, data_size)
		for i in range(len(recording_buffer)):
			for j in range(audio_sample_size):
				var k: int = 44 + 4*(i*audio_sample_size + j)
				recording_data.encode_s16(k, clampi(recording_buffer[i][j].x*32768, -32768, 32767))
				recording_data.encode_s16(k+2, clampi(recording_buffer[i][j].y*32768, -32768, 32767))
		wav_recording = AudioStreamWAV.load_from_buffer(recording_data)

		$RecordButton.text = "Record"
		$Status.text = ""
		recording_buffer = null

func _on_play_button_pressed() -> void:
	print_rich("\n[b]Playing recording:[/b] %s" % wav_recording)
	$AudioWav.stream = wav_recording
	$AudioWav.play()

func _on_play_music_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$AudioMusic.play()
		$PlayMusic.text = "Stop Music"
	else:
		$AudioMusic.stop()
		$PlayMusic.text = "Play Music"

func _on_save_button_pressed() -> void:
	var save_path: String = $SaveButton/Filename.text
	wav_recording.save_to_wav(save_path)
	$Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]


func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


# 400Hz frequency can be used (from another device) to probe a stereo microphone
# response due to where there should be 8 wavelengths in the space of 20ms (2.5ms per wave).
# The wavelength is then 343/400=0.8575m long.
func _on_option_tone_item_selected(index: int) -> void:
	if index != 0:
		$AudioGenerator.playing = true
		if not $MicToGenerator.button_pressed and not $PlayMusic.button_pressed:
			generator_freq = int($OptionTone.get_item_text(index))
	else:
		generator_freq = 0.0
