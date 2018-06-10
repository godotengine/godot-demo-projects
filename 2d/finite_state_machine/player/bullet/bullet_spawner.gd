extends Node2D

var bullet = preload("Bullet.tscn")

func fire(direction):
	if not $CooldownTimer.is_stopped():
		return

	$CooldownTimer.start()
	var new_bullet = bullet.instance()
	new_bullet.direction = direction
	add_child(new_bullet)


func update(host, delta):
	return 'previous'
