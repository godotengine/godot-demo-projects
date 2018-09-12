extends Node

const Actor = preload("../actors/Actor.gd")

export (NodePath) var actors_node
var queue = [] setget set_queue
var active_actor = null setget _set_active_actor

signal active_actor_changed(active_actor)

func _ready():
	actors_node = get_node(actors_node)
	initialize()

func initialize():
	set_queue(actors_node.get_children())

func play_turn():
	yield(active_actor, "turn_finished")
	get_next_in_queue()
	play_turn()

func get_next_in_queue():
	var current_actor = queue.pop_front()
	current_actor.active = false
	queue.append(current_actor)
	self.active_actor = queue[0]
	return active_actor
	
func remove(actor):
	var new_queue = []
	for n in queue:
		new_queue.append(n)
	new_queue.remove(new_queue.find(actor))
	actor.queue_free()
	self.queue = new_queue

func set_queue(new_queue):
	queue.clear()
	var names = []
	for node in new_queue:
		if not node is Actor:
			continue
		queue.append(node)
		node.active = false
	if queue.size() > 0:
		self.active_actor = queue[0]

func _set_active_actor(new_actor):
	active_actor = new_actor
	active_actor.active = true
	emit_signal("active_actor_changed", active_actor)