extends Control

export (NodePath) var actors_node
export (PackedScene) var actor_info

func _ready():
	actors_node = get_node(actors_node)
	
func initialize():
	for actor in actors_node.get_children():
		var health = actor.get_node("Health")
		var info = actor_info.instance()
		var health_info = info.get_node("VBoxContainer/Health")
		health_info.value = health.life
		health_info.max_value = health.max_life
		info.get_node("VBoxContainer/Name").text = actor.name
		health.connect("health_changed", health_info, "set_value")
		$Actors.add_child(info)

func _on_Attack_button_up():
	if not actors_node.get_node("Player").active:
		return
	actors_node.get_node("Player").attack(actors_node.get_node("Opponent"))

func _on_Deffend_button_up():
	if not actors_node.get_node("Player").active:
		return
	actors_node.get_node("Player").deffend()

func _on_Flee_button_up():
	if not actors_node.get_node("Player").active:
		return
	actors_node.get_node("Player").flee()
	get_parent().emit_signal("combat_finished", $"../Actors/Opponent")
