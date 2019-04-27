extends Panel

const BPM = 116
const BARS = 4

var playing = false
const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

func strsec(secs):
	var s = str(secs)
	if (s.length()==1):
		s="0"+s
	return s
	
# warning-ignore:unused_argument
func _process(delta):
	if (!playing or !$Player.playing):
		return
	
	var time = $Player.get_mix_time() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1/COMPENSATE_HZ)*COMPENSATE_FRAMES
		
	var beat = int(time * BPM / 60.0)
	var seconds = int(time)
	var seconds_total = int($Player.stream.get_length())
	$Label.text = str("BEAT: ",beat % BARS +1,"/",BARS," TIME: ",seconds/60,":",strsec(seconds%60)," / ",seconds_total/60,":",strsec(seconds_total%60))
	

func _on_Button_pressed():
	print(AudioServer.get_output_latency())
	playing=true
	$Player.play()

