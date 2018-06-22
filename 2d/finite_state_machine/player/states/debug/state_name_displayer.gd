extends Label

var start_position = Vector2()

func _ready():
	start_position = rect_position

func _physics_process(delta):
	rect_position = $"../BodyPivot".position + start_position

func _on_StateMachine_state_changed(current_state):
	text = current_state.get_name()
