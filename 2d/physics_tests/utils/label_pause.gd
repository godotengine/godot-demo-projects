extends Label


func _process(_delta):
	visible = get_tree().paused
