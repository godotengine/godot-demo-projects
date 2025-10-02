extends Label

var start_position := Vector2()

func _ready() -> void:
	start_position = position


func _physics_process(_delta: float) -> void:
	position = $"../BodyPivot".position + start_position


func _on_StateMachine_state_changed(current_state: Node) -> void:
	text = String(current_state.name)
