
extends Panel

func _on_back_pressed():
	var scene = load("res://main.tscn")
	var si = scene.instance()
	get_parent().add_child(si)
	queue_free()
