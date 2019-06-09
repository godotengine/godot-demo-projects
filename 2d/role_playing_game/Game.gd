extends Node

export (NodePath) var combat_screen
export (NodePath) var exploration_screen

const PLAYER_WIN = "res://dialogue/dialogue_data/player_won.json"
const PLAYER_LOSE = "res://dialogue/dialogue_data/player_lose.json"

func _ready():
	exploration_screen = get_node(exploration_screen)
	combat_screen = get_node(combat_screen)
	combat_screen.connect("combat_finished", self, "_on_combat_finished")
	for n in $Exploration/Grid.get_children():
		if not n.type == n.CELL_TYPES.ACTOR:
			continue
		if not n.has_node("DialoguePlayer"):
			continue
		n.get_node("DialoguePlayer").connect("dialogue_finished", self, 
			"_on_opponent_dialogue_finished", [n])
	remove_child(combat_screen)

func _on_opponent_dialogue_finished(opponent):
	if opponent.lost:
		return
	var player = $Exploration/Grid/Player
	var combatents = [player.combat_actor, opponent.combat_actor]
	start_combat(combatents)
	
func start_combat(combat_actors):
	remove_child($Exploration)
	$AnimationPlayer.play("fade")
	yield($AnimationPlayer, "animation_finished")
	add_child(combat_screen)
	combat_screen.show()
	combat_screen.initialize(combat_actors)
	$AnimationPlayer.play_backwards("fade")
	
func _on_combat_finished(winner, loser):
	remove_child(combat_screen)
	$AnimationPlayer.play_backwards("fade")
	add_child(exploration_screen)
	var dialogue = load("res://dialogue/dialogue_player/DialoguePlayer.tscn").instance()
	if winner.name == "Player":
		dialogue.dialogue_file = PLAYER_WIN
	else:
		dialogue.dialogue_file = PLAYER_LOSE
	yield($AnimationPlayer, "animation_finished")
	var player = $Exploration/Grid/Player
	exploration_screen.get_node("DialogueUI").show_dialogue(player, dialogue)
	combat_screen.clear_combat()
	yield(dialogue, "dialogue_finished")
	dialogue.queue_free()
