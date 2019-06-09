extends Node


var hz = 22050.0 # less samples to mix, GDScript is not super fast for this
var phase = 0.0

var pulse_hz = 440.0
var playback = null #object that does the actual playback

func _fill_buffer():
	var increment = (1.0 / (hz / pulse_hz)) 
		
	var to_fill = playback.get_frames_available()
	while (to_fill > 0):
		playback.push_frame( Vector2(1.0,1.0) * sin(phase * (PI * 2.0)) ) # frames are stereo
		phase = fmod((phase + increment), 1.0)
		to_fill-=1;

func _process(delta):
	_fill_buffer()

	
func _ready():
	$player.stream.mix_rate=hz #setting hz is only possible before playing
	playback = $player.get_stream_playback()
	_fill_buffer() # prefill, do before play to avoid delay 
	$player.play() # start

