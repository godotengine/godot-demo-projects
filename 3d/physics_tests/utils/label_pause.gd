extends Label


func _process(_delta: float) -> void:
	visible = get_tree().paused
