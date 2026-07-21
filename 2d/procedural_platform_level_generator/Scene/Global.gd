extends Node2D

func _process(delta):
	pass

func _on_tile_map_game_over():
	$Player.set_physics_process(false)
	$Game_over.play()

func _on_game_over_finished():
	get_tree().reload_current_scene()
