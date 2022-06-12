# Sorts all Node25D children of its parent.
# This is different from the C# version of this project
# because the execution order is different and otherwise
# sorting is delayed by one frame.
tool
extends Node # Note: NOT Node2D, Node25D, or YSort
class_name YSort25D, "res://addons/node25d/icons/y_sort_25d_icon.png"

# Whether or not to automatically call sort() in _process().
export(bool) var sort_enabled := true
var _parent_node: Node2D # NOT Node25D


func _ready():
	_parent_node = get_parent()


func _process(_delta):
	if sort_enabled:
		sort()


# Call this method in _process, or whenever you want to sort children.
func sort():
	if _parent_node == null:
		return # _ready() hasn't been run yet
	var parent_children = _parent_node.get_children()
	if parent_children.size() > 4000:
		# The Z index only goes from -4096 to 4096, and we want room for objects having multiple layers.
		printerr("Sorting failed: Max number of YSort25D nodes is 4000.")
		return

	# We only want to get Node25D children.
	# Currently, it also grabs Node2D children.
	var node25d_nodes = []
	for n in parent_children:
		if n.get_class() == "Node2D":
			node25d_nodes.append(n)
	node25d_nodes.sort_custom(Node25D, "y_sort_slight_xz")

	var z_index = -4000
	for i in range(0, node25d_nodes.size()):
		node25d_nodes[i].z_index = z_index
		# Increment by 2 each time, to allow for shadows in-between.
		# This does mean that we have a limit of 4000 total sorted Node25Ds.
		z_index += 2
