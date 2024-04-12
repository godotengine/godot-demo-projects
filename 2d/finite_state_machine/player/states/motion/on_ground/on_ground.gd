extends "../motion.gd"

# warning-ignore-all:unused_class_variable
var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump"):
		finished.emit("jump")
	return super.handle_input(event)
