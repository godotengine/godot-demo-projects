extends CanvasLayer


func _ready() -> void:
	hide()
	if DisplayServer.is_touchscreen_available():
		show()
