## Extend from CanvasLayer for Rendering HUD objects in this specific layer
extends CanvasLayer

## Initialize a signal to notify the main scene when to start the game.
signal start_game

## Called when you click on the "New Game" button in the HUD.
## the variable text is the text to display in the message label.
## When the function is called, it shows the message specified in text.
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

## Called in the main.gd when the player hits a mob.
func show_game_over():
	## Show the "Game Over" message for 2 seconds.
	show_message("Game Over")
	## Wait for the message timer to time out before showing the start button.
	## Using await to pause the function until the timer times out.
	## This requires Godot 4.0 or later.
	## You can also use a yield() in Godot 3.x, but await is preferred in Godot 4.x.
	## It sequentially waits for the timer to finish before proceeding to the next line.
	## ==> Good game flow control technique <==
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	## Show the message label again just to be sure it is visible.
	$MessageLabel.show()
	## Wait for 1 second before showing the start button.
	## This gives the player a moment to read the message.
	## the timer is created on the fly using create_timer().
	## We don't need to add a Timer node in the scene for this.
	## again await is used to pause the function until the timer times out.
	## ==> Another good game flow control technique <==
	await get_tree().create_timer(1).timeout
	## Finally, show the start button to allow the player to start a new game.
	$StartButton.show()

## Called in main.gd to update the score display in the HUD.
## It adds +1 each time the timer times out.
func update_score(score):
	## Update the ScoreLabel text with the new score.
	## Convert the score to a string using str() function.
	## Because the text property expects a string not an integer.
	$ScoreLabel.text = str(score)

## Called when the StartButton is pressed.
## Signal made in the editor at the start button node.
func _on_StartButton_pressed():
	$StartButton.hide()
	## Emit the start_game signal to notify the main scene to start the game.
	## We have to connect this signal in main.gd to a function that starts the game.
	## We connect it in the main.tscn file using the editor.
	## In the editor, select the HUD node, go to the Node tab,
	## find the start_game signal, and connect it to main.gd.
	start_game.emit()

## Called when the MessageTimer times out.
## The Timer starts when we call show_message().
## Again like a signal function.
## you can check the MessageTimer node in the editor to see its wait time.
## Little trick to hide the message label after showing it for a short time.
## the signal is embedded in the HUD scene.
func _on_MessageTimer_timeout():
	$MessageLabel.hide()
