extends Node2D

func _on_switch_pressed():
	$switch.hide()
	background_load.load_scene("res://paintings.tscn")
