extends Node

signal dead
signal health_changed(life)

export var life = 0
export var max_life = 10
export var armor = 0

func take_damage(damage):
	var applied_damage = max(damage - armor, 0)
	life = max(life - applied_damage, 0)
	if life == 0:
		emit_signal('dead')
	else:
		emit_signal("health_changed", life)

func heal(amount):
	life += amount
	clamp(life, life, max_life)
	emit_signal("health_changed", life)

func get_health_ratio():
	return life / max_life
