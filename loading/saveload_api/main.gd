extends Node2D

const save_file : String = "res://test_save"
const enemy_scene : PackedScene = preload("res://enemy.tscn")

@onready var enemies : Node2D = $Enemies


func _unhandled_key_input(event : InputEvent) -> void:
	if event.is_action_pressed("save"):
		SaveloadAPI.save(save_file)
	elif event.is_action_pressed("open"):
		SaveloadAPI.load(save_file)
	elif event.is_action_pressed("spawn"):
		var enemy : Node2D = enemy_scene.instantiate()
		enemy.position = Vector2(randf() * 600, randf() * 600)
		enemies.add_child(enemy, true)
