extends Spatial

# Has this tile been visited before by the maze generation algorithm?
var visited = false

# A dictionary to store which walls are active.
# Because the maze generation algorithm destroys walls, we make them all true by default
var walls = {"NORTH":true, "SOUTH":true, "EAST":true, "WEST":true}


func _ready():
	walls = {"NORTH":true, "SOUTH":true, "EAST":true, "WEST":true}


# A simple function that makes walls and pillars if they are needed
func setup_walls():
	for wall_name in walls.keys():
		if walls[wall_name]:
			show_wall(wall_name)
		else:
			delete_wall(wall_name)
	
	setup_pillars()


func setup_pillars():
	var pillars = {"NE":false, "NW":false, "SE":false, "SW":false}

	# Figure out which pillars are needed
	if walls["NORTH"]:
		pillars["NE"] = true
		pillars["NW"] = true
	if walls["SOUTH"]:
		pillars["SE"] = true
		pillars["SW"] = true
	if walls["EAST"]:
		pillars["NE"] = true
		pillars["SE"] = true
	if walls["WEST"]:
		pillars["NW"] = true
		pillars["SW"] = true
	
	if pillars["NE"]:
		get_node("Pillars/NE").visible = true
	else:
		get_node("Pillars/NE").queue_free()
	
	if pillars["NW"]:
		get_node("Pillars/NW").visible = true
	else:
		get_node("Pillars/NW").queue_free()
	
	if pillars["SE"]:
		get_node("Pillars/SE").visible = true
	else:
		get_node("Pillars/SE").queue_free()
	
	if pillars["SW"]:
		get_node("Pillars/SW").visible = true
	else:
		get_node("Pillars/SW").queue_free()


func show_wall(wall_name):
	if wall_name == "NORTH":
		get_node("Walls/North").visible = true
	elif wall_name == "SOUTH":
		get_node("Walls/South").visible = true
	elif wall_name == "EAST":
		get_node("Walls/East").visible = true
	elif wall_name == "WEST":
		get_node("Walls/West").visible = true
	else:
		print ("Maze_tile: Unknown wall passed into show_wall")
	return


func delete_wall(wall_name):
	if wall_name == "NORTH":
		get_node("Walls/North").queue_free()
	elif wall_name == "SOUTH":
		get_node("Walls/South").queue_free()
	elif wall_name == "EAST":
		get_node("Walls/East").queue_free()
	elif wall_name == "WEST":
		get_node("Walls/West").queue_free()
	else:
		print ("Maze_tile: Unknown wall passed into delete_wall")
		return

