class_name Combatant
extends Node


signal turn_finished

export(int) var damage = 1
export(int) var defense = 1

var active = false setget set_active



func set_active(value):
	active = value
	set_process(value)
	set_process_input(value)

	if not active:
		return
	if $Health.armor >= $Health.base_armor + defense:
		$Health.armor = $Health.base_armor


func attack(target):
	target.take_damage(damage)
	emit_signal("turn_finished")


func consume(item):
	item.use(self)
	emit_signal("turn_finished")


func defend():
	$Health.armor += defense
	emit_signal("turn_finished")


func flee():
	emit_signal("turn_finished")


func take_damage(damage_to_take):
	$Health.take_damage(damage_to_take)
	$Sprite/AnimationPlayer.play("take_damage")
