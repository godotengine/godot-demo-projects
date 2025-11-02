## User interface layer displaying score, messages, and start button
## See README: Node Inheritance & Types
## CanvasLayer provides separate rendering layer for UI elements
extends CanvasLayer

## See README: Signals
## Emitted when player presses start button to begin game
signal start_game

func show_message(text):
	## Display temporary message
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	## See README: await - Asynchronous flow control
	## Pauses execution until timer finishes, creates sequential game flow
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	## See README: create_timer()
	## Creates temporary timer without adding a node to the scene beforehand
	await get_tree().create_timer(1).timeout
	$StartButton.show()

func update_score(score):
	## Update score display
	$ScoreLabel.text = str(score)

func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_MessageTimer_timeout():
	$MessageLabel.hide()
