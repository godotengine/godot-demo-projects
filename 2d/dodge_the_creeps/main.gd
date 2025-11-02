## Central game orchestrator managing game state, score, and mob spawning
## See README: Node Inheritance & Types, Architecture Overview
## Node is the base container, manages game flow via signals and timers
extends Node

## See README: @export - Editor-exposed variables
## Allows assigning the Mob scene from the inspector
@export var mob_scene: PackedScene
var score

func game_over():
	## Stop all timers and show game over screen
	## See README: Dollar sign ($)
	## $ is shorthand for get_node()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	## See README: Groups & call_group(), queue_free()
	## Calls queue_free() on all nodes in "mobs" group to delete them safely
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_MobTimer_timeout():
	## Spawn a new mob at random location along path
	var mob = mob_scene.instantiate()

	## See README: Path2D & Random Spawning, Caret symbol (^)
	## Uses Path2D to spawn mobs randomly along screen edges, ^ means parent level
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()
	mob.position = mob_spawn_location.position

	## Set mob direction perpendicular to path
	## See README: Rotation in radians
	## Godot uses radians internally, PI/2 makes mob move perpendicular to path
	var direction = mob_spawn_location.rotation + PI / 2

	## See README: Random direction
	## Adds randomness to make mob movement less predictable
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	## Set random velocity and apply direction
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	## Start game timers after brief delay
	$MobTimer.start()
	$ScoreTimer.start()
