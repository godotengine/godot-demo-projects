extends Label

func _process(_delta: float) -> void:
	text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
