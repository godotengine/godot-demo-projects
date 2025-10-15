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
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
