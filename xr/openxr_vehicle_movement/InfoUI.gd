extends CanvasLayer

func set_velocity(p_velocity : float):
	%Velocity.text = "Velocity: %0.2f kmph (%0.2f m/s)" % [ p_velocity * 3.6, p_velocity ]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	%FPS.text = "FPS: " + str(Engine.get_frames_per_second())
