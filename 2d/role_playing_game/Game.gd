extends Node


@export var combat_screen: NodePath
@export var exploration_screen: NodePath

const PLAYER_WIN = "res://dialogue/dialogue_data/player_won.json"
const PLAYER_LOSE = "res://dialogue/dialogue_data/player_lose.json"

@onready var combat_node = get_node(combat_screen);
@onready var exploration_node = get_node(exploration_screen);


func _ready():
	combat_node.combat_finished.connect(self._on_combat_finished)
	for n in $Exploration/Grid.get_children():
		if not n.type == n.CellType.ACTOR:
			continue
		if not n.has_node("DialoguePlayer"):
			continue
		print(n.get_node(^"DialoguePlayer"))
		n.get_node(^"DialoguePlayer").dialogue_finished.connect(self._on_opponent_dialogue_finished.bind(n))
	remove_child(combat_node)


func start_combat(combat_actors):
	remove_child($Exploration)
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	add_child(combat_node)
	combat_node.show()
	combat_node.initialize(combat_actors)
	$AnimationPlayer.play_backwards("fade")


func _on_opponent_dialogue_finished(opponent):
	if opponent.lost:
		return
	var player = $Exploration/Grid/Player
	var combatants = [player.combat_actor, opponent.combat_actor]
	start_combat(combatants)


func _on_combat_finished(winner, _loser):
	remove_child(combat_node)
	$AnimationPlayer.play_backwards("fade")
	add_child(exploration_node)
	var dialogue = load("res://dialogue/dialogue_player/DialoguePlayer.tscn").instantiate()
	if winner.name == "Player":
		dialogue.dialogue_file = PLAYER_WIN
	else:
		dialogue.dialogue_file = PLAYER_LOSE
	await $AnimationPlayer.animation_finished
	var player = $Exploration/Grid/Player
	exploration_node.get_node(^"DialogueUI").show_dialogue(player, dialogue)
	combat_node.clear_combat()
	await dialogue.dialogue_finished
	dialogue.queue_free()
