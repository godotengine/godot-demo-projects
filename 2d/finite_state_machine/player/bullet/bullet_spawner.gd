extends Node2D

var bullet = preload("Bullet.tscn")


func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		fire()


func fire():
	if not $CooldownTimer.is_stopped():
		return

	$CooldownTimer.start()
	var new_bullet = bullet.instance()
	new_bullet.position = global_position
	new_bullet.direction = owner.look_direction
	add_child(new_bullet)
