extends Control

export(NodePath) var combatants_node
export(PackedScene) var info_scene

func _ready():
	combatants_node = get_node(combatants_node)


func initialize():
	for combatant in combatants_node.get_children():
		var health = combatant.get_node("Health")
		var info = info_scene.instance()
		var health_info = info.get_node("VBoxContainer/Health")
		health_info.value = health.life
		health_info.max_value = health.max_life
		info.get_node("VBoxContainer/Name").text = combatant.name
		health.connect("health_changed", health_info, "set_value")
		$Combatants.add_child(info)
	$Buttons/GridContainer/Attack.grab_focus()


func _on_Attack_button_up():
	if not combatants_node.get_node("Player").active:
		return
	combatants_node.get_node("Player").attack(combatants_node.get_node("Opponent"))


func _on_Defend_button_up():
	if not combatants_node.get_node("Player").active:
		return
	combatants_node.get_node("Player").defend()


func _on_Flee_button_up():
	if not combatants_node.get_node("Player").active:
		return
	combatants_node.get_node("Player").flee()
	var loser = combatants_node.get_node("Player")
	var winner = combatants_node.get_node("Opponent")
	get_parent().finish_combat(winner, loser)
