extends Node2D

const SCORE_TO_WIN = 10

var score_left = 0
var score_right = 0

signal game_finished()

sync func update_score(add_to_left):
	if add_to_left:
		score_left += 1
		get_node("score_left").set_text(str(score_left))
	else:
		
		score_right += 1
		get_node("score_right").set_text(str(score_right))
		
	var game_ended = false
	
	if score_left == SCORE_TO_WIN:
		get_node("winner_left").show()
		game_ended = true
	elif score_right == SCORE_TO_WIN:
		get_node("winner_right").show()
		game_ended = true
		
	if game_ended:
		get_node("exit_game").show()
		get_node("ball").rpc("stop")

func _on_exit_game_pressed():
	emit_signal("game_finished")	

func _ready():
	# by default, all nodes in server inherit from master
	# while all nodes in clients inherit from puppet
	if get_tree().is_network_server():		
		#if in the server, get control of player 2 to the other peeer, this function is tree recursive by default
		get_node("player2").set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		#if in the client, give control of player 2 to itself, this function is tree recursive by default
		get_node("player2").set_network_master(get_tree().get_network_unique_id())
	
	#let each paddle know which one is left, too
	get_node("player1").left = true
	get_node("player2").left = false
	print("unique id: ", get_tree().get_network_unique_id())
