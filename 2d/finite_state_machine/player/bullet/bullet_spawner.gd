extends Node2D

var bullet = preload("Bullet.tscn")

func _input(event):
	if event.is_action_pressed("fire"):
		fire(owner.look_direction)

func fire(direction):
	if not $CooldownTimer.is_stopped():
		return

	$CooldownTimer.start()
	var new_bullet = bullet.instance()
	new_bullet.direction = direction
	add_child(new_bullet)
