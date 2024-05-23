extends Node2D

var bullet := preload("Bullet.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		fire()


func fire() -> void:
	if not $CooldownTimer.is_stopped():
		return

	$CooldownTimer.start()
	var new_bullet := bullet.instantiate()
	add_child(new_bullet)
	new_bullet.position = global_position
	new_bullet.direction = owner.look_direction
