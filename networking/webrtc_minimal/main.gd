extends Node

const Chat = preload("res://chat.gd")

func _ready():
	var p1 = Chat.new()
	var p2 = Chat.new()
	add_child(p1)
	add_child(p2)

	# Wait a second and send message from P1
	yield(get_tree().create_timer(1), "timeout")
	p1.send_message("Hi from %s" % p1.get_path())

	# Wait a second and send message from P2
	yield(get_tree().create_timer(1), "timeout")
	p2.send_message("Hi from %s" % p2.get_path())