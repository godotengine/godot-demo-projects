extends Node

const Chat = preload("res://chat.gd")

func _ready() -> void:
	var p1 := Chat.new()
	var p2 := Chat.new()
	add_child(p1)
	add_child(p2)

	# Wait a second and send message from P1.
	await get_tree().create_timer(1.0).timeout
	p1.send_message("Hi from %s" % String(p1.get_path()))

	# Wait a second and send message from P2.
	await get_tree().create_timer(1.0).timeout
	p2.send_message("Hi from %s" % String(p2.get_path()))
