extends Control

var wav_recording: AudioStreamWAV
var input_mix_rate : int = 44100
var audio_chunk_size_ms : int = 20
var audio_sample_size : int = 882

var total_samples : int = 0
var sample_duration : float = 0.0
var recording_buffer : Variant = null

var audio_sample_image : Image
var audio_sample_texture : ImageTexture

func _ready() -> void:
	if not Input.has_method("start_microphone"):
		$Status.text = "Error: requires PR#105244 to work"
	input_mix_rate = int(AudioServer.get_input_mix_rate())
	$InputMixRate.text = "Mix rate: %d" % input_mix_rate
	audio_sample_size = int(audio_chunk_size_ms*input_mix_rate/1000.0)
	var blank_image : PackedVector2Array = PackedVector2Array()
	blank_image.resize(audio_sample_size)
	audio_sample_image = Image.create_from_data(audio_sample_size, 1, false, Image.FORMAT_RGF, blank_image.to_byte_array())
	audio_sample_texture = ImageTexture.create_from_image(audio_sample_image)
	$MicTexture.material.set_shader_parameter("audiosample", audio_sample_texture)

func _on_microphone_on_toggled(toggled_on : bool) -> void:
	if toggled_on:
		Input.start_microphone()
		total_samples = 0
		sample_duration = 0.0
	else:
		Input.stop_microphone()

func _on_mic_to_generator_toggled(toggled_on : bool) -> void:
	$AudioGenerator.playing = toggled_on

func _process(delta : float) -> void:
	sample_duration += delta
	while true:
		var audio_samples : PackedVector2Array = Input.get_microphone_buffer(audio_sample_size)
		if not audio_samples:
			break
		audio_sample_image.set_data(audio_sample_size, 1, false, Image.FORMAT_RGF, audio_samples.to_byte_array())
		audio_sample_texture.update(audio_sample_image)
		total_samples += 1
		$SampleCount.text = "%.0f samples/sec" % (total_samples*audio_sample_size/sample_duration)
		if recording_buffer != null:
			recording_buffer.append(audio_samples)
		if $MicToGenerator.button_pressed:
			$AudioGenerator.get_stream_playback().push_buffer(audio_samples)

func _on_record_button_toggled(toggled_on : bool) -> void:
	total_samples = 0
	sample_duration = 0.0
	if toggled_on:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		recording_buffer = [ ]
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."
		$AudioGenerator.get_stream_playback().clear_buffer()
		
	else:
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		var recording_data : PackedByteArray = PackedByteArray()
		var data_size : int = 4*audio_sample_size*len(recording_buffer)
		recording_data.resize(44 + data_size)
		recording_data.encode_u32(0, 0x46464952) # RIFF
		recording_data.encode_u32(4, len(recording_data) - 8)
		recording_data.encode_u32(8, 0x45564157) # WAVE
		recording_data.encode_u32(12, 0x20746D66) # 'fmt '
		recording_data.encode_u32(16, 16)
		recording_data.encode_u16(20, 1)
		recording_data.encode_u16(22, 2)
		recording_data.encode_u32(24, input_mix_rate)
		recording_data.encode_u32(28, input_mix_rate*16*2/8)
		recording_data.encode_u16(32, 16*2/8)
		recording_data.encode_u16(34, 16)
		recording_data.encode_u32(36, 0x61746164) # 'data'
		recording_data.encode_u32(40, data_size)
		for i in range(len(recording_buffer)):
			for j in range(audio_sample_size):
				var k : int = 44 + 4*(i*audio_sample_size + j) 
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

func _on_play_music_toggled(toggled_on : bool) -> void:
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
	
