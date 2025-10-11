extends Node

signal combat_finished(winner: Combatant, loser: Combatant)


@onready var ui := $CombatCanvas/UI


func _ready() -> void:
	ui.flee.connect(_on_flee)


func _on_flee(winner: Combatant, loser: Combatant) -> void:
	finish_combat(winner, loser)


func initialize(combat_combatants: Array[PackedScene]) -> void:
	for combatant_scene in combat_combatants:
		var combatant := combatant_scene.instantiate()
		if combatant is Combatant:
			$Combatants.add_combatant(combatant)
			combatant.get_node(^"Health").dead.connect(_on_combatant_death.bind(combatant))
		else:
			combatant.queue_free()
	ui.initialize()
	$TurnQueue.initialize()


func clear_combat() -> void:
	for n in $Combatants.get_children():
		# Player characters.
		n.queue_free()
	for n in ui.get_node(^"Combatants").get_children():
		# Health bars.
		n.queue_free()


func finish_combat(winner: Combatant, loser: Combatant) -> void:
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
