extends Node2D

signal game_finished()

const SCORE_TO_WIN = 10

var score_left := 0
var score_right := 0

@onready var player2: Area2D = $Player2
@onready var score_left_node: Label = $ScoreLeft
@onready var score_right_node: Label = $ScoreRight
@onready var winner_left: Label = $WinnerLeft
@onready var winner_right: Label = $WinnerRight

func _ready() -> void:
	# By default, all nodes in server inherit from master,
	# while all nodes in clients inherit from puppet.
	# set_multiplayer_authority is tree-recursive by default.
	if multiplayer.is_server():
		# For the server, give control of player 2 to the other peer.
		player2.set_multiplayer_authority(multiplayer.get_peers()[0])
	else:
		# For the client, give control of player 2 to itself.
		player2.set_multiplayer_authority(multiplayer.get_unique_id())

	print("Unique id: ", multiplayer.get_unique_id())


@rpc("any_peer", "call_local")
func update_score(add_to_left: int) -> void:
	if add_to_left:
		score_left += 1
		score_left_node.set_text(str(score_left))
	else:
		score_right += 1
		score_right_node.set_text(str(score_right))

	var game_ended := false
	if score_left == SCORE_TO_WIN:
		winner_left.show()
		game_ended = true
	elif score_right == SCORE_TO_WIN:
		winner_right.show()
		game_ended = true

	if game_ended:
		$ExitGame.show()
		$Ball.stop.rpc()


func _on_exit_game_pressed() -> void:
	game_finished.emit()
