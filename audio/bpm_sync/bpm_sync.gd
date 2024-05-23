extends Panel

enum SyncSource {
	SYSTEM_CLOCK,
	SOUND_CLOCK,
}

const BPM = 116
const BARS = 4

const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

var playing := false
var sync_source := SyncSource.SYSTEM_CLOCK

# Used by system clock.
var time_begin: float
var time_delay: float


func _process(_delta: float) -> void:
	if not playing or not $Player.playing:
		return

	var time := 0.0
	if sync_source == SyncSource.SYSTEM_CLOCK:
		# Obtain from ticks.
		time = (Time.get_ticks_usec() - time_begin) / 1000000.0
		# Compensate.
		time -= time_delay
	elif sync_source == SyncSource.SOUND_CLOCK:
		time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES

	var beat := int(time * BPM / 60.0)
	var seconds := int(time)
	var seconds_total := int($Player.stream.get_length())
	@warning_ignore("integer_division")
	$Label.text = str("BEAT: ", beat % BARS + 1, "/", BARS, " TIME: ", seconds / 60, ":", str(seconds % 60).pad_zeros(2), " / ", seconds_total / 60, ":", str(seconds_total % 60).pad_zeros(2))


func _on_PlaySystem_pressed() -> void:
	sync_source = SyncSource.SYSTEM_CLOCK
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	playing = true
	$Player.play()


func _on_PlaySound_pressed() -> void:
	sync_source = SyncSource.SOUND_CLOCK
	playing = true
	$Player.play()
