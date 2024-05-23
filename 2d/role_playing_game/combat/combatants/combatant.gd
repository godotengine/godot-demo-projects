class_name Combatant
extends Node

signal turn_finished

@export var damage := 1
@export var defense := 1

var active := false: set = set_active

func set_active(value: bool) -> void:
	active = value
	set_process(value)
	set_process_input(value)

	if not active:
		return
	if $Health.armor >= $Health.base_armor + defense:
		$Health.armor = $Health.base_armor


func attack(target: Combatant) -> void:
	target.take_damage(damage)
	turn_finished.emit()


func defend() -> void:
	$Health.armor += defense
	turn_finished.emit()


func flee() -> void:
	turn_finished.emit()


func take_damage(damage_to_take: float) -> void:
	$Health.take_damage(damage_to_take)
	$Sprite2D/AnimationPlayer.play("take_damage")
