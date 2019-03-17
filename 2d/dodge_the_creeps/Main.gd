extends Node

export (PackedScene) var Mob
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
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_MobTimer_timeout():
	$MobPath/MobSpawnLocation.offset = randi()
	var mob = Mob.instance()
	add_child(mob)
	var direction = $MobPath/MobSpawnLocation.rotation + PI/2
	mob.position = $MobPath/MobSpawnLocation.position
	direction += rand_range(-PI/4, PI/4)
	mob.rotation = direction
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0).rotated(direction)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()