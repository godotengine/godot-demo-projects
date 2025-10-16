extends CanvasLayer

## Initialize a signal to notify the main scene when to start the game.
signal start_game

## Called when you click on the "New Game" button in the HUD.
## the vaiable Text is the text to display in the message label.
## When the function is called, it shows the message specified in text.
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

## Called in the main.gd when the player hits a mob.
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
