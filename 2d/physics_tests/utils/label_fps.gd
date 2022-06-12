extends Label


func _process(_delta):
	set_text("FPS: %d" % Engine.get_frames_per_second())
