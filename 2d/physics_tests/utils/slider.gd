extends Slider


export(float) var snap_step = 1.0


func _process(_delta):
	if Input.is_key_pressed(KEY_SHIFT):
		step = 0.1
	else:
		step = snap_step
