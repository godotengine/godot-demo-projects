tool
extends Node2D

# Set a random color to all objects in the "walls" group.
# To use, attach this script to the "Walls" node.

func _ready():
	randomize()
	var walls = get_tree().get_nodes_in_group("walls")
	for wall in walls:
		wall.modulate = Color(randf(), randf(), randf())
