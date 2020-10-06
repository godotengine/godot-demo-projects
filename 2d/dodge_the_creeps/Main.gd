extends Node

export(PackedScene) var _mob_scene
var score

func _ready():
	randomize()


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation");
	mob_spawn_location.offset = randi()

	# Create a Mob instance and add it to the scene.
	var mob_instance = _mob_scene.instance()
	add_child(mob_instance)

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + TAU / 4

	# Set the mob's position to a random location.
	mob_instance.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += rand_range(-TAU / 8, TAU / 8)
	mob_instance.rotation = direction

	# Choose the velocity.
	mob_instance.linear_velocity = Vector2(rand_range(mob_instance.min_speed, mob_instance.max_speed), 0).rotated(direction)


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
