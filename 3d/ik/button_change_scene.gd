extends Button

@export_file var scene_to_change_to: String = null


func _ready():
	pressed.connect(self.change_scene)


func change_scene():
	if scene_to_change_to != null:
		get_tree().change_scene(scene_to_change_to)
