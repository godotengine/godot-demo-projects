extends LineEdit

@export var submit_button: Button

func _ready() -> void:
	text_submitted.connect(func(_s): clear(), ConnectFlags.CONNECT_DEFERRED)
	if submit_button: submit_button.pressed.connect(func(): text_submitted.emit(text))
