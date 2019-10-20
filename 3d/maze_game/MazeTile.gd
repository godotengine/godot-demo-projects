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
		get_node("Meshes/Pillar_NE").visible = true
	else:
		get_node("Meshes/Pillar_NE").visible = false
		get_node("StaticBody/Pillar_NE_CollisionShape").disabled = true
	
	if pillars["NW"]:
		get_node("Meshes/Pillar_NW").visible = true
	else:
		get_node("Meshes/Pillar_NW").visible = false
		get_node("StaticBody/Pillar_NW_CollisionShape").disabled = true
	
	if pillars["SE"]:
		get_node("Meshes/Pillar_SE").visible = true
	else:
		get_node("Meshes/Pillar_SE").visible = false
		get_node("StaticBody/Pillar_SE_CollisionShape").disabled = true
	
	if pillars["SW"]:
		get_node("Meshes/Pillar_SW").visible = true
	else:
		get_node("Meshes/Pillar_SW").visible = false
		get_node("StaticBody/Pillar_SW_CollisionShape").disabled = true


func show_wall(wall_name):
	if wall_name == "NORTH":
		get_node("Meshes/Wall_North").visible = true
		get_node("StaticBody/Wall_North_CollisionShape").disabled = false
	elif wall_name == "SOUTH":
		get_node("Meshes/Wall_South").visible = true
		get_node("StaticBody/Wall_South_CollisionShape").disabled = false
	elif wall_name == "EAST":
		get_node("Meshes/Wall_East").visible = true
		get_node("StaticBody/Wall_East_CollisionShape").disabled = false
	elif wall_name == "WEST":
		get_node("Meshes/Wall_West").visible = true
		get_node("StaticBody/Wall_West_CollisionShape").disabled = false
	else:
		print ("Maze_tile: Unknown wall passed into show_wall")
	return


func delete_wall(wall_name):
	if wall_name == "NORTH":
		get_node("Meshes/Wall_North").visible = false
		get_node("StaticBody/Wall_North_CollisionShape").disabled = true
	elif wall_name == "SOUTH":
		get_node("Meshes/Wall_South").visible = false
		get_node("StaticBody/Wall_South_CollisionShape").disabled = true
	elif wall_name == "EAST":
		get_node("Meshes/Wall_East").visible = false
		get_node("StaticBody/Wall_East_CollisionShape").disabled = true
	elif wall_name == "WEST":
		get_node("Meshes/Wall_West").visible = false
		get_node("StaticBody/Wall_West_CollisionShape").disabled = true
	else:
		print ("Maze_tile: Unknown wall passed into delete_wall")
		return

