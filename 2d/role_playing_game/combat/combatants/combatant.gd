class_name Combatant
extends Node


signal turn_finished

@export var damage: int = 1
@export var defense: int = 1

var active = false: set = set_active



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
	turn_finished.emit()


func consume(item):
	item.use(self)
	turn_finished.emit()


func defend():
	$Health.armor += defense
	turn_finished.emit()


func flee():
	turn_finished.emit()


func take_damage(damage_to_take):
	$Health.take_damage(damage_to_take)
	$Sprite2D/AnimationPlayer.play("take_damage")
