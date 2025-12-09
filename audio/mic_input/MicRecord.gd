extends Control

@onready var input_mix_rate: int = AudioServer.get_input_mix_rate()
var audio_chunk_time: float = 0.02
@onready var audio_sample_size: int = int(input_mix_rate * audio_chunk_time + 0.5)

var recording_start_time: float = 0.0
var recording_buffer: Variant = null
var recording_time: float = 0.0
@onready var max_recording_buffer_size: int = int(10 / audio_chunk_time)

var previous_recording: Variant = null
var previous_recording_index: int = 0

var microphone_active: bool = false

var audio_sample_image: Image
var audio_sample_texture: ImageTexture
var generator_timestamp: float = 0.0
var generator_freq: float = 0.0

var guessed_generator_feedback_buffer_frames: int = 1
@onready var pitch_shift_effect: AudioEffectPitchShift = AudioServer.get_bus_effect(1, 0)

func _ready() -> void:
	for d in AudioServer.get_input_device_list():
		%OptionInput.add_item(d)
	assert(%OptionInput.get_item_text(%OptionInput.selected) == "Default")

	for d in AudioServer.get_output_device_list():
		%OptionOutput.add_item(d)
	assert(%OptionOutput.get_item_text(%OptionOutput.selected) == "Default")

	print("Output mix rate: ", AudioServer.get_mix_rate())
	print("Project mix rate: ", ProjectSettings.get(&"audio/driver/mix_rate"))

	if not AudioServer.has_method("get_input_frames"):
		%Status.text = "**** Error: requires https://github.com/godotengine/godot/pull/113288 to work" 
		print(%Status.text)
		set_process(false)
		$MicrophoneOn.disabled = true
		return

	await get_tree().create_timer(0.5).timeout
	%MicrophoneOn.button_pressed = true


func _on_option_input_item_selected(index: int) -> void:
	var input_device: String = %OptionInput.get_item_text(index)
	print("Set input device: ", input_device)
	AudioServer.set_input_device(input_device)

func _on_option_output_item_selected(index: int) -> void:
	var output_device: String = %OptionOutput.get_item_text(index)
	print("Set output device: ", output_device)
	AudioServer.set_output_device(output_device)

func _on_microphone_on_toggled(toggled_on: bool, source_button: Variant) -> void:
	if toggled_on:
		if OS.get_name() == "Android" and not OS.request_permission("android.permission.RECORD_AUDIO"):
			print("Waiting for user response after requesting audio permissions")
			# Must enable Record Audio permission in on Android
			@warning_ignore("untyped_declaration")
			var x = await get_tree().on_request_permissions_result
			var permission: String = x[0]
			var granted: bool = x[1]
			assert(permission == "android.permission.RECORD_AUDIO")
			print("Audio permission granted ", granted)

		var err: int = AudioServer.set_input_device_active(true)
		if err != OK:
			print("Input device error: ", err)
			source_button.button_pressed = false
			return

		on_microphone_input_start()
		print("Input buffer length frames: ", AudioServer.get_input_buffer_length_frames())
		print("Input buffer length seconds: ", AudioServer.get_input_buffer_length_frames() * 1.0 / input_mix_rate)
		microphone_active = true

	else:
		AudioServer.set_input_device_active(false)
		microphone_active = false

	%OptionInput.disabled = microphone_active

func on_microphone_input_start() -> void:
	input_mix_rate = AudioServer.get_input_mix_rate()
	audio_sample_size = int(input_mix_rate * audio_chunk_time + 0.5)
	max_recording_buffer_size = int(10 / audio_chunk_time)
	print("Input mix rate: ", input_mix_rate)
	print("Sample size: ", audio_sample_size)
	%InputMixRate.text = "Mix rate: %d" % input_mix_rate

	$AudioGeneratorFeedback.stream.mix_rate = input_mix_rate
	guessed_generator_feedback_buffer_frames = nearest_po2(int(input_mix_rate * $AudioGeneratorFeedback.stream.buffer_length))
	print("guessed_generator_feedback_buffer_frames ", guessed_generator_feedback_buffer_frames)
	
	var blank_image: PackedVector2Array = PackedVector2Array()
	blank_image.resize(audio_sample_size)
	audio_sample_image = Image.create_from_data(audio_sample_size, 1, false, Image.FORMAT_RGF, blank_image.to_byte_array())
	audio_sample_texture = ImageTexture.create_from_image(audio_sample_image)
	%MicTexture.material.set_shader_parameter(&"audiosample", audio_sample_texture)

func _on_mic_to_generator_toggled(toggled_on: bool) -> void:
	$AudioGeneratorFeedback.playing = toggled_on

func _process_tone_generator() -> void:
	var gplayback: AudioStreamGeneratorPlayback = $AudioGeneratorTone.get_stream_playback()
	var gdt: float = 1.0 / $AudioGeneratorTone.stream.mix_rate
	for i in range(gplayback.get_frames_available()):
		var a: float = 0.5 * sin(generator_timestamp * generator_freq * TAU)
		gplayback.push_frame(Vector2(a, a))
		generator_timestamp += gdt

func _process(delta: float) -> void:
	while AudioServer.get_input_frames_available() >= audio_sample_size:
		var audio_samples: PackedVector2Array = AudioServer.get_input_frames(audio_sample_size)
		if audio_samples:
			audio_sample_image.set_data(audio_sample_size, 1, false, Image.FORMAT_RGF, audio_samples.to_byte_array())
			audio_sample_texture.update(audio_sample_image)
			if recording_buffer != null and len(recording_buffer) < max_recording_buffer_size:
				recording_time = Time.get_ticks_msec() * 0.001 - recording_start_time
				var nframes = len(recording_buffer)*audio_sample_size
				recording_buffer.append(audio_samples)
				%RecInfo.text = "Frames: %d  Time: %.3f Frames/sec: %.0f" % [nframes, recording_time, nframes / recording_time]

			if %MicToGenerator.button_pressed:
				if %RecordingToGenerator.button_pressed:
					audio_samples = previous_recording[previous_recording_index]
					previous_recording_index += 1
					if previous_recording_index == len(previous_recording):
						previous_recording_index = 0
				$AudioGeneratorFeedback.get_stream_playback().push_buffer(audio_samples)

	if %MicToGenerator.button_pressed:
		if microphone_active:
			adjust_feedback_speed()

	if generator_freq != 0.0 and $AudioGeneratorTone.playing:
		_process_tone_generator()

func adjust_feedback_speed():
	var target_time_lag: float = %PlaybackLag.value - AudioServer.get_time_to_next_mix()
	var buffer_time_lag: float = (guessed_generator_feedback_buffer_frames - $AudioGeneratorFeedback.get_stream_playback().get_frames_available())*1.0/$AudioGeneratorFeedback.stream.mix_rate
	%RealLagLabel.text = "Real lag: %.2f" % (buffer_time_lag + AudioServer.get_time_to_next_mix())
	var buffer_time_mismatch = buffer_time_lag - target_time_lag
	if $AudioGeneratorFeedback.stream_paused:
		if buffer_time_mismatch > 0.0:
			print("Unpausing stream at target mismatch: ", buffer_time_mismatch)
			$AudioGeneratorFeedback.stream_paused = false
			$AudioGeneratorFeedback.pitch_scale = 1.0
			pitch_shift_effect.pitch_scale = 1.0
	elif buffer_time_mismatch < -0.1:
			print("Pausing stream at target mismatch: ", buffer_time_mismatch)
			$AudioGeneratorFeedback.stream_paused = true
	elif $AudioGeneratorFeedback.pitch_scale != 1.0:
		if buffer_time_mismatch < 0.0:
			print("Set pitch=1 at target mismatch: ", buffer_time_mismatch)
			$AudioGeneratorFeedback.pitch_scale = 1.0
			pitch_shift_effect.pitch_scale = 1.0
	elif buffer_time_mismatch > 0.1:
		if $AudioGeneratorFeedback.pitch_scale == 1.0:
			$AudioGeneratorFeedback.pitch_scale = 1.5
			print("Set pitch=", $AudioGeneratorFeedback.pitch_scale, " at target mismatch: ", buffer_time_mismatch)
			pitch_shift_effect.pitch_scale = 0.667

func _on_record_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		recording_buffer = [ ]
		recording_start_time = Time.get_ticks_msec() * 0.001
		%RecordButton.text = "Stop"
		%Status.text = "Status: Recording..."
	else:
		previous_recording = recording_buffer
		previous_recording_index = 0
		recording_buffer = null
		$AudioWav.stream = null
		%RecordButton.text = "Record"
		%Status.text = ""
		%SaveButton.disabled = false
		%PlayRecording.disabled = false

func buffer_to_wav(buffer: Variant) -> AudioStreamWAV:
	var recording_data: PackedByteArray = PackedByteArray()
	var data_size: int = 4 * audio_sample_size * len(buffer)
	recording_data.resize(44 + data_size)
	recording_data.encode_u32(0, 0x46464952) # RIFF
	recording_data.encode_u32(4, len(recording_data) - 8)
	recording_data.encode_u32(8, 0x45564157) # WAVE
	recording_data.encode_u32(12, 0x20746D66) # 'fmt '
	recording_data.encode_u32(16, 16)
	recording_data.encode_u16(20, 1)
	recording_data.encode_u16(22, 2)
	recording_data.encode_u32(24, input_mix_rate)
	recording_data.encode_u32(28, input_mix_rate * 4) # *16*2/8
	recording_data.encode_u16(32, 4) # 16*2/8
	recording_data.encode_u16(34, 16)
	recording_data.encode_u32(36, 0x61746164) # 'data'
	recording_data.encode_u32(40, data_size)
	for i in range(len(buffer)):
		for j in range(audio_sample_size):
			var k: int = 44 + 4 * (i * audio_sample_size + j)
			recording_data.encode_s16(k, clampi(buffer[i][j].x * 32768, -32768, 32767))
			recording_data.encode_s16(k + 2, clampi(buffer[i][j].y * 32768, -32768, 32767))
	print("Recording data size bytes: ", len(recording_data))
	return AudioStreamWAV.load_from_buffer(recording_data)

func _on_play_recording_pressed() -> void:
	assert (previous_recording != null)
	if $AudioWav.stream == null:
		$AudioWav.stream = buffer_to_wav(previous_recording)
		$AudioWav.stream.mix_rate = input_mix_rate
	$AudioWav.seek(0.0)
	$AudioWav.play()
	%PlayRecording.text = "Playing Wav"

func _on_audio_wav_finished() -> void:
	%PlayRecording.text = "Play Recording"

func _on_play_music_toggled(toggled_on: bool, source_button: Variant) -> void:
	if toggled_on:
		$AudioMusic.play()
		source_button.text = "Stop Music"
	else:
		$AudioMusic.stop()
		source_button.text = "Play Music"

func _on_save_button_pressed() -> void:
	var save_path: String = %WavFilename.text
	assert (previous_recording != null)
	if $AudioWav.stream == null:
		$AudioWav.stream = buffer_to_wav(previous_recording)
	$AudioWav.stream.save_to_wav(save_path)
	%Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]

func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))

# A chunk size of 20ms is will be 8 wavelengths at 400Hz per chunk, 
# where the wavelength will be 343/400=0.8575m long.
# Use this to plot the response of a stereo microphone.
func _on_option_tone_item_selected(index: int) -> void:
	if index != 0:
		$AudioGeneratorTone.playing = true
		generator_freq = int(%OptionTone.get_item_text(index))
	else:
		$AudioGeneratorTone.playing = false
		generator_freq = 0.0
