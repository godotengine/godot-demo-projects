extends Control

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	scale = Vector2.ONE * (1 - abs(sin(time * 4)) / 4)
