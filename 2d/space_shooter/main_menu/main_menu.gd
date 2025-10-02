extends Control

# get a reference to the score label
onready var score_label = get_node("VBoxContainer/score")
# set up a string format template for the high score display
const HIGH_SCORE_TEXT = "HIGH SCORE: %d"

func _ready():
	# game_state is an Autoloaded Singleton (see Project Settings), making it globally available and persistent
	game_state.menu = self
	# grab the current highscore from game_state and update the score label
	score_label.set_text(HIGH_SCORE_TEXT % game_state.max_points)

# response function for the "play" button's "pressed" signal
# the connection is set up on the "play" node, using the "Signals" sub-tab in the "Node" dock
func _on_play_pressed():
	# tell the game_state to start a new game, which resets the current score to 0 and switches to the level scene
	game_state.start_game()
