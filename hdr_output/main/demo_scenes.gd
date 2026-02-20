extends Node

@export var scenes: Array[Control]


func _ready() -> void:
	_on_demo_scene_item_selected(0)


func _on_demo_scene_item_selected(index: int) -> void:
	for i in range(scenes.size()):
		scenes[i].visible = i == index
