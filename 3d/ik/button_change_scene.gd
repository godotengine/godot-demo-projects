extends Button

@export_file var scene_to_change_to: String = null


func _ready():
	# warning-ignore:return_value_discarded
	connect(&"pressed", self.change_scene)


func change_scene():
	if scene_to_change_to != null:
		# warning-ignore:return_value_discarded
		get_tree().change_scene(scene_to_change_to)
