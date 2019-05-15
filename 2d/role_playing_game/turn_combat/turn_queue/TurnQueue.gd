extends Node

const combatant = preload("../combatants/Combatant.gd")

export (NodePath) var combatants_list
var queue = [] setget set_queue
var active_combatant = null setget _set_active_combatant

signal active_combatant_changed(active_combatant)

func _ready():
	combatants_list = get_node(combatants_list)

func initialize():
	set_queue(combatants_list.get_children())
	play_turn()

func play_turn():
	yield(active_combatant, "turn_finished")
	get_next_in_queue()
	play_turn()

func get_next_in_queue():
	var current_combatant = queue.pop_front()
	current_combatant.active = false
	queue.append(current_combatant)
	self.active_combatant = queue[0]
	return active_combatant
	
func remove(combatant):
	var new_queue = []
	for n in queue:
		new_queue.append(n)
	new_queue.remove(new_queue.find(combatant))
	combatant.queue_free()
	self.queue = new_queue

func set_queue(new_queue):
	queue.clear()
	for node in new_queue:
		if not node is combatant:
			continue
		queue.append(node)
		node.active = false
	if queue.size() > 0:
		self.active_combatant = queue[0]

func _set_active_combatant(new_combatant):
	active_combatant = new_combatant
	active_combatant.active = true
	emit_signal("active_combatant_changed", active_combatant)
