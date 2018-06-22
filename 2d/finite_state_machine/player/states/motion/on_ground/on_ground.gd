extends "../motion.gd"

var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jump")
	return .handle_input(event)
