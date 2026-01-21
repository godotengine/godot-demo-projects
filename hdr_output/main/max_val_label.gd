extends Label


func _process(_delta: float) -> void:
	text = "%0.2f" % get_window().get_output_max_linear_value()
