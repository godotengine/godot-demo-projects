extends Button

export(String, FILE) var scene_to_change_to = null


func _ready():
	# warning-ignore:return_value_discarded
	connect("pressed", self, "change_scene")


func change_scene():
	if scene_to_change_to != null:
		# warning-ignore:return_value_discarded
		get_tree().change_scene(scene_to_change_to)
