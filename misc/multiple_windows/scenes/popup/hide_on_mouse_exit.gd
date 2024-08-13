extends Popup

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_exited():
	hide()
