@tool
extends Label


func _process(_delta: float) -> void:
	var slider: HSlider = get_node(^"../HSlider")
	text = "%.1f" % slider.value
