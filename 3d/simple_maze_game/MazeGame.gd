extends Spatial

# NOTE: this maze generation algorithm is based on the growing tree algorithm found in the link below.
# the code is modified to work in Godot, but the link below has the algorithm this demo is based on.
# (http://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm)


# The data for the maze
var data = []
# all of the cells (the tiles we need to process)
var cells = []
const DIRECTIONS = {"NORTH":Vector2(0, -1), "SOUTH":Vector2(0, 1), "EAST":Vector2(1, 0), "WEST":Vector2(-1, 0)}
const OPPOSITE_DIRECTIONS = {"NORTH":"SOUTH", "SOUTH":"NORTH", "EAST":"WEST", "WEST":"EAST"}

var player = null
var AI = null
var key = null

# The stored nav_mesh (for the AI)
var nav_mesh

# The tile and how big each tile is in Godot units (NOTE: it is assumed every maze tile is a square)
const MAZE_TILE_PREFAB = preload("res://MazeTile.tscn")
const TILE_SIZE = 2

# This is the size of the maze, in tiles
# NOTE: the larger the maze, the longer it takes to generate!
export (Vector2) var Maze_size = Vector2(14, 14)
# Should we generate an imperfect maze (one with multiple paths to a goal)
export (bool) var Generate_imperfect_maze = false
# What is the chance we'll remove a wall when we find a tile we've already visited?
export (float, 0, 100) var Imperfect_maze_wall_removal_chance = 25

func _ready():
	
	# Generate the maze and the nav_mesh
	generate(Maze_size)
	generate_nav_mesh(Maze_size)
	
	# Place the key somewhere in the maze
	place_key(Maze_size)
	# Place the AI somewhere in the maze
	place_ai(Maze_size)
	# Place the player somewhere in the maze
	place_player(Maze_size)
	
	# Add/Remove walls and pillars from the maze tiles
	# NOTE: you could do post processing on the maze here! (like adding decorations to the walls, etc)
	for x in range(0, Maze_size.x):
		for y in range(0, Maze_size.y):
			var tile = data[x][y]
			tile.setup_walls()


func generate(size):
	
	# Erase all of the objects in data, if there is any to erase.
	if data.size() > 0:
		for x in range(0, data.size()-1):
			for y in range(0, data[0].size()-1):
				var obj = data[x][y]
				obj.queue_free()
	data = []
	
	# NOTE: We put all of the tiles in the 'Tiles' node so it's easier to inspect in the remote inspector
	var tiles_node_holder = get_node("Tiles")
	
	# Add all of the tiles to data
	for x in range(0, size.x):
		var row = []
		for y in range(0, size.y):
			var clone = MAZE_TILE_PREFAB.instance()
			tiles_node_holder.add_child(clone)
			clone.global_transform.origin = Vector3(x * TILE_SIZE, 0, y * TILE_SIZE)
			row.push_front(clone)
		data.push_front(row)
	
	# Randomly chose a tile to start generating the maze at
	var x = round(rand_range(0, size.x-1))
	var y = round(rand_range(0, size.y-1))
	cells.push_front([x, y])
	
	# Process the cells. A cell is a node we have not visited before but is adjacent to a cell we have
	# visited before (with the expection being the very first tile)
	while cells.size() > 0:
		
		# Select a cell using the get_cell_index function and get it's X and Y position
		var index = get_cell_index(cells)
		x = cells[index][0]
		y = cells[index][1]
		
		# Shuffle the DIRECTIONS array to make chosing a direction random.
		var dirs_keys = shuffleArray(DIRECTIONS.keys())
		
		for dir in dirs_keys:
			
			# Get the position of the tile looking for with the proper direction offset.
			var nx = x + DIRECTIONS[dir].x
			var ny = y + DIRECTIONS[dir].y
			# Get the opposite direction.
			var opp_dir = OPPOSITE_DIRECTIONS[dir]
			# NOTE: We use direction to remove the wall in the tile we're in, and we use the opposite
			# direction to remove the wall in the tile we're going to.
			
			# Is this (potential) tile we're looking for inside the maze map?
			if nx >= 0 && ny >= 0 && nx < size.x && ny < size.y:
				
				# Have we visited this tile before?
				if data[nx][ny].visited:
					if Generate_imperfect_maze:
						if rand_range(0, 100) <= Imperfect_maze_wall_removal_chance:
							data[x][y].walls[dir] = false
							data[nx][ny].walls[opp_dir] = false
				
				# Otherwise we have not been to this tile before and we should remove the walls so these tiles can connect
				else:
					data[x][y].walls[dir] = false
					data[nx][ny].walls[opp_dir] = false
					data[nx][ny].visited = true
			
					# Push the cell we've just connected with to cells, so it can be processed
					cells.push_front([nx, ny])
					index = null
		
		if index != null:
			# If this tile has only visited tiles around it, then we should remove it.
			cells.remove(index)


func generate_nav_mesh(size):
	
	# A couple pool arrays for holding verticies and indicies for the navmesh.
	# We have to use pool arrays because that is what mesh uses.
	var verticies = PoolVector3Array()
	var indicies = PoolIntArray()
	
	# Go through every tile
	for x in range(0, size.x):
		for y in range(0, size.y):
		
			var tile = data[x][y]
			var quad = null
			var pos = tile.get_transform().origin
			
			# Add the main floor, that is ALWAYS present
			quad = add_quad(pos + Vector3(0, 0, 0), Vector3(0.9, 1, 0.9), verticies, indicies)
			verticies = quad[0]
			indicies = quad[1]
			
			# Add the directional floors. These floors are the quads under the walls, so each tile only
			# connects with tiles that have no walls in the way
			
			# North floor
			if tile.walls["NORTH"] == false:
				quad = add_quad(pos + Vector3(0, 0, 0.95), Vector3(0.9, 1, 0.05), verticies, indicies)
				verticies = quad[0]
				indicies = quad[1]
			
			# South floor
			if tile.walls["SOUTH"] == false:
				quad = add_quad(pos + Vector3(0, 0, -0.95), Vector3(0.9, 1, 0.05), verticies, indicies)
				verticies = quad[0]
				indicies = quad[1]
			
			# East floor
			if tile.walls["EAST"] == false:
				quad = add_quad(pos + Vector3(-0.95, 0, 0), Vector3(0.05, 1, 0.9), verticies, indicies)
				verticies = quad[0]
				indicies = quad[1]
			
			# West floor
			if tile.walls["WEST"] == false:
				quad = add_quad(pos + Vector3(0.95, 0, 0), Vector3(0.05, 1, 0.9), verticies, indicies)
				verticies = quad[0]
				indicies = quad[1]
	
	
	# If we want to see the nav_mesh (using a mesh instance), then change this to true.
	# It's easier to understand how the navmesh is constructed when you can see it!
	var DRAW_MESH = false
	
	# Make a new mesh and surface tool. Tell the surface tool to begin and that we'll be passing triangles
	var mesh = Mesh.new()
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Add all of the verticies and indicies
	for vert in verticies:
		surface.add_vertex(vert)
	for indie in indicies:
		surface.add_index(indie)
	
	# Tell the surface tool we are done. Assign the mesh that the surface tool generated to the 'mesh' variable
	mesh = surface.commit()
	
	# Create a new navigation mesh and create it's navmesh from the mesh we've just generated
	nav_mesh = NavigationMesh.new()
	nav_mesh.create_from_mesh(mesh)
	
	# If we are drawing the mesh, then assign the mesh to the mesh instance too
	if DRAW_MESH:
		get_node("DebugNavmesh").mesh = mesh
	else:
		get_node("DebugNavmesh").queue_free()
	


func add_quad(quad_center, quad_size, quad_verticies, quad_indicies):
	
	# Check if a there is a vertex at the position we're considering. If there is, then we can use that.
	# This is so we can make a mesh that has no floating triangles (floating triangles do not work with navmeshes)
	var vert_index_BL = findInPoolArray(quad_verticies, Vector3(quad_center.x - quad_size.x, quad_center.y, quad_center.z + quad_size.z))
	var vert_index_TL = findInPoolArray(quad_verticies, Vector3(quad_center.x - quad_size.x, quad_center.y, quad_center.z - quad_size.z))
	var vert_index_TR = findInPoolArray(quad_verticies, Vector3(quad_center.x + quad_size.x, quad_center.y, quad_center.z - quad_size.z))
	var vert_index_BR = findInPoolArray(quad_verticies, Vector3(quad_center.x + quad_size.x, quad_center.y, quad_center.z + quad_size.z))
	
	# If we're missing a vertex, then add it
	if vert_index_BL == -1:
		quad_verticies.append(Vector3(quad_center.x - quad_size.x, quad_center.y, quad_center.z + quad_size.z)) # Bottom left corner
		vert_index_BL = quad_verticies.size() - 1
	if vert_index_TL == -1:
		quad_verticies.append(Vector3(quad_center.x - quad_size.x, quad_center.y, quad_center.z - quad_size.z)) # Top left corner
		vert_index_TL = quad_verticies.size() - 1
	if vert_index_TR == -1:
		quad_verticies.append(Vector3(quad_center.x + quad_size.x, quad_center.y, quad_center.z - quad_size.z)) # Top right corner
		vert_index_TR = quad_verticies.size() - 1
	if vert_index_BR == -1:
		quad_verticies.append(Vector3(quad_center.x + quad_size.x, quad_center.y, quad_center.z + quad_size.z)) # Bottom right corner
		vert_index_BR = quad_verticies.size() - 1
	
	# indices order: [0,1,2,0,2,3]
	quad_indicies.append(vert_index_BL)
	quad_indicies.append(vert_index_TL)
	quad_indicies.append(vert_index_TR)
	quad_indicies.append(vert_index_BL)
	quad_indicies.append(vert_index_TR)
	quad_indicies.append(vert_index_BR)
	
	return [quad_verticies, quad_indicies]


func get_cell_index(cells):
	# We are getting a random cell, but based on which cell you select
	# you can get different types of mazes!
	return round(rand_range(0, cells.size()-1))


func get_empty_tile_position(size):
	var tile_found = false
	var tile_x = null
	var tile_y = null
	
	while tile_found == false:
		# Get a random position
		tile_x = round(rand_range(0, size.x-1))
		tile_y = round(rand_range(0, size.y-1))
		var tile = data[tile_x][tile_y]
		
		# If this tile is enclosed, skip it
		if tile.walls["NORTH"] and tile.walls["SOUTH"] and tile.walls["EAST"] and tile.walls["WEST"]:
			continue
		
		# If this tile is enclosed by it's neighbors, skip it
		var neighbor_walls = []
		if tile_x - 1 >= 0:
			var other_tile = data[tile_x -1][tile_y]
			if other_tile.walls["WEST"]:
				neighbor_walls.append("WEST")
		if tile_x + 1 < size.x:
			var other_tile = data[tile_x +1][tile_y]
			if other_tile.walls["EAST"]:
				neighbor_walls.append("EAST")
		if tile_y - 1 >= 0:
			var other_tile = data[tile_x][tile_y - 1]
			if other_tile.walls["NORTH"]:
				neighbor_walls.append("NORTH")
		if tile_y + 1 < size.y:
			var other_tile = data[tile_x][tile_y + 1]
			if other_tile.walls["SOUTH"]:
				neighbor_walls.append("SOUTH")
		
		if neighbor_walls.size() >= 4:
			continue
		
		
		# If none of the above checks pass, then we've found a tile we can use
		tile_found = true
	
	return [tile_x, tile_y]


func place_key(size):
	var tile_pos = get_empty_tile_position(size)
	var tile = data[tile_pos[0]][tile_pos[1]]
	
	# Place the key
	key = get_node("Key")
	key.global_transform.origin = tile.global_transform.origin
	print ("Placed KEY at:", tile.global_transform.origin)
	key.ready = true


func place_ai(size):
	var tile_pos = get_empty_tile_position(size)
	var tile = data[tile_pos[0]][tile_pos[1]]
	
	AI = get_node("AI")
	# Give it a navmesh instance
	var navmesh_instance = NavigationMeshInstance.new()
	navmesh_instance.navmesh = nav_mesh
	navmesh_instance.set_enabled(true)
	AI.add_child(navmesh_instance)
	# Place the AI at the proper position and call it's setup function
	AI.setup(tile.global_transform.origin)
	print ("Placed AI at:", tile.global_transform.origin)


func place_player(size):
	var tile_pos = get_empty_tile_position(size)
	var tile = data[tile_pos[0]][tile_pos[1]]
	
	# Place the player
	player = get_node("Player")
	player.global_transform.origin = tile.global_transform.origin + Vector3(0, 0.1, 0)
	player.key = key
	player.AI = AI
	print ("Placed player at:", tile.global_transform.origin)


# A generic array shuffling function
func shuffleArray(array):
	var i = array.size() - 1
	while i > 0:
		var j = floor(randf() * (i + 1))
		var temp = array[i]
		array[i] = array[j]
		array[j] = array[i]
		i -= 1
	
	return array


# A function to find an element in a PoolArray.
# NOTE: there are probably faster/better ways to make a find function!
func findInPoolArray(array, obj):
	for i in range(0, array.size()):
		if array[i] == obj:
			return i
	return -1

