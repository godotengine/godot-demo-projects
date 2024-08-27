extends Control

@onready var title: VBoxContainer = $TitleScreen
@onready var start: HBoxContainer = $StartGame
@onready var options: Control = $Options


func _on_Start_pressed() -> void:
	start.visible = true
	title.visible = false


func _on_Options_pressed() -> void:
	options.prev_menu = title
	options.visible = true
	title.visible = false


func _on_Exit_pressed() -> void:
	get_tree().quit()


func _on_RandomBlocks_pressed() -> void:
	Settings.world_type = 0
	get_tree().change_scene_to_packed(preload("res://world/world.tscn"))


func _on_FlatGrass_pressed() -> void:
	Settings.world_type = 1
	get_tree().change_scene_to_packed(preload("res://world/world.tscn"))


func _on_BackToTitle_pressed() -> void:
	title.visible = true
	start.visible = false
