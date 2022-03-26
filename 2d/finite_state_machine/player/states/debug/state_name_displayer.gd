extends Label

var start_position = Vector2()

func _ready():
	start_position = position


func _physics_process(_delta):
	position = $"../BodyPivot".position + start_position


func _on_StateMachine_state_changed(current_state):
	text = String(current_state.get_name())
