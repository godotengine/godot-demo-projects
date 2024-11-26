extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(_on_close_requested)


func _on_close_requested():
	print("%s %s was hidden." % [str(self.get_class()), name])
	hide()
