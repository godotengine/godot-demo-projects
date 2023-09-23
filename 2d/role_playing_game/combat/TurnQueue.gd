extends Node


@export var combatants_list: NodePath

@onready var combatants_list_node = get_node(combatants_list)

var queue = []:
	set(value):
		# TODO: Manually copy the code from this method.
		set_queue(value)

var active_combatant = null:
	set(value):
		# TODO: Manually copy the code from this method.
		_set_active_combatant(value)

signal active_combatant_changed(active_combatant)


func initialize():
	set_queue(combatants_list_node.get_children())
	play_turn()


func play_turn():
	await active_combatant.turn_finished
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
		if not node is Combatant:
			continue
		queue.append(node)
		node.active = false
	if queue.size() > 0:
		self.active_combatant = queue[0]


func _set_active_combatant(new_combatant):
	active_combatant = new_combatant
	active_combatant.active = true
	emit_signal("active_combatant_changed", active_combatant)
