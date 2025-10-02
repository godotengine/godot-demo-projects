extends Button

@export_file var scene_to_change_to: String = ""


func _ready():
	pressed.connect(change_scene)


func change_scene():
	if not scene_to_change_to.is_empty():
		get_tree().change_scene_to_file(scene_to_change_to)
