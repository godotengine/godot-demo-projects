extends Node

## @export is for exposing variables in the editor.
## Now we can assign the Mob scene in the inspector.
@export var mob_scene: PackedScene
var score

## Function called once when the player hits a mob.
## Because it's a signal, we don't call it directly in the code.
## Instead, we connect it in the editor.
func game_over():
	## Stop all the game timers and game elements.
	## the Dollar sign ($) is a shorthand for get_node().
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

## Called once when you click on the "New Game" button in the HUD.
func new_game():
	## Clear out any remaining mobs.
	## call_group() calls a method on all nodes in a group.
	## We added all mobs to the "mobs" group in the Mob scene.
	## queue_free() is a safe way to delete a node. So we call it on all mobs.
	get_tree().call_group(&"mobs", &"queue_free")
	## Reset the score.
	score = 0
	## Start the player and timers.
	## The player is hidden at the start of the game.
	## We called the start() function in player.gd to initialize it.
	$Player.start($StartPosition.position)
	$StartTimer.start()
	## TODO : Update the HUD to show the score and a "Get Ready" message.
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

## Called in a loop every time the MobTimer times out.
## Called exactly like a signal function.
func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	## Get the MobSpawnLocation node inside the MobPath node.
	## Be Careful with the path.
	## Don't move the MobSpawnLocation node out of the MobPath node.
	## If you do, the path will break and you'll get an error.
	## The ^ symbol is a shorthand for ".." which means "go up one level".
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	## Set the progress of the MobSpawnLocation to a random integer
	## between 0 and 2^32 - 1.
	## progress is a value that represents the position along the path.
	mob_spawn_location.progress = randi()

	## Quick note: if you want to generate a random float between 0 and 1
	## use randf() function which returns a random float between 0.0 and 1.0
	## and change the progress of the MobSpawnLocation to .progress_ratio
	## mob_spawn_location.progress_ratio = randf()
	

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	## Notice in the editor that the MobSpawnLocation rotate following the path.
	## So we can use its rotation to determine the direction of the mob.
	## We add PI/2 to make the mob move perpendicular to the path.
	## Remember that in Godot, a rotation is in radians.
	## Even though we set the rotation in degrees in the editor,
	## Godot converts it to radians internally.
	## If you want to use degrees instead of radians,
	## you can rotation_degrees property instead of rotation.
	## EXAMPLE : var direction = mob_spawn_location.rotation_degrees + 90
	## So here we set the direction to point inwards the screen.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	## randf_range(a, b) returns a random float between a and b.
	## Here we add a random value between -PI/4 and PI/4 to the direction.
	## This makes the mob's movement less predictable and more interesting.
	direction += randf_range(-PI / 4, PI / 4)
	## finally, set the mob's rotation to the direction.
	mob.rotation = direction

	# Choose the velocity for the mob.
	## We create a velocity vector with a random x value between 150 and 250.
	## and a y value of 0.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	## then we rotate the vector of the mob to point in the direction we set.
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

## Called when the ScoreTimer times out.
## Again like a signal function.
## Check the ScoreTimer node in the editor to see how often it times out.
func _on_ScoreTimer_timeout():
	score += 1
	## Update the HUD with the new score.
	## We call the update_score() function in hud.gd to update the score display.
	$HUD.update_score(score)

## Called when the StartTimer times out.
## This timer is a one-shot timer that starts the game after a short delay.
## We use it to give the player a moment to get ready.
## It starts the other timers that control the game.
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
