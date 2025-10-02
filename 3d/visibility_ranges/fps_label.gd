extends Label


func _process(_delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	text = "%d FPS (%.2f mspf)" % [fps, 1000.0 / fps]
