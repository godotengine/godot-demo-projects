extends Panel

const BPM = 116
const BARS = 4

var playing = false
const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

const SYNC_SOURCE_SYSTEM_CLOCK = 0
const SYNC_SOURCE_SOUND_CLOCK = 1

var sync_source = SYNC_SOURCE_SYSTEM_CLOCK


func strsec(secs):
	var s = str(secs)
	if (s.length()==1):
		s="0"+s
	return s
	
# used by system clock
var time_begin 
var time_delay

func _process(delta):
	if (!playing or !$Player.playing):
		return
	
	var time 
	if (sync_source == SYNC_SOURCE_SYSTEM_CLOCK): 
		# obtain from ticks
		time = (OS.get_ticks_usec() - time_begin) / 1000000.0
		# compensate
		time -= time_delay		
	elif (sync_source == SYNC_SOURCE_SOUND_CLOCK):		
		time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1/COMPENSATE_HZ)*COMPENSATE_FRAMES
		
	var beat = int(time * BPM / 60.0)
	var seconds = int(time)
	var seconds_total = int($Player.stream.get_length())
	$Label.text = str("BEAT: ",beat % BARS +1,"/",BARS," TIME: ",seconds/60,":",strsec(seconds%60)," / ",seconds_total/60,":",strsec(seconds_total%60))
	


func _on_PlaySystem_pressed():
	pass # Replace with function body.
	sync_source = SYNC_SOURCE_SYSTEM_CLOCK
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	playing=true
	$Player.play()


func _on_PlaySound_pressed():
	sync_source = SYNC_SOURCE_SOUND_CLOCK
	playing=true
	$Player.play()
	
