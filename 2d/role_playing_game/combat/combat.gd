extends Node

signal combat_finished(winner: Combatant, loser: Combatant)


func initialize(combat_combatants: Array[PackedScene]) -> void:
	for combatant_scene in combat_combatants:
		var combatant := combatant_scene.instantiate()
		if combatant is Combatant:
			$Combatants.add_combatant(combatant)
			combatant.get_node("Health").dead.connect(_on_combatant_death.bind(combatant))
		else:
			combatant.queue_free()
	$UI.initialize()
	$TurnQueue.initialize()


func clear_combat() -> void:
	for n in $Combatants.get_children():
		n.queue_free()
	for n in $UI/Combatants.get_children():
		n.queue_free()


func finish_combat(winner: Combatant, loser: Combatant) -> void:
	# FIXME: Error calling from signal 'combat_finished' to callable:
	# 'Node(game.gd)::_on_combat_finished': Cannot convert argument 1 from Object to Object.
	combat_finished.emit(winner, loser)


func _on_combatant_death(combatant: Combatant) -> void:
	var winner: Combatant
	if not combatant.name == "Player":
		winner = $Combatants/Player
	else:
		for n in $Combatants.get_children():
			if not n.name == "Player":
				winner = n
				break

	finish_combat(winner, combatant)
