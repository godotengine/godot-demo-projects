extends TileMap

enum CellType { ACTOR, OBSTACLE, OBJECT }
@export var dialogue_ui: NodePath

func _ready():
	for child in get_children():
		#TODO
		#set_cellv(local_to_map(child.position), child.type)
		print(get_layers_count())
		# set_cell? (int layer, Vector2i coords, int source_id=-1, Vector2i atlas_coords=Vector2i(-1, -1), int alternative_tile=0)
		# https://docs.godotengine.org/en/latest/classes/class_tilemap.html#class-tilemap-method-set-cell
		#set_cell(local_to_map(child.position), child.type)


func get_cell_pawn(cell, type = CellType.ACTOR):
	for node in get_children():
		if node.type != type:
			continue
		if local_to_map(node.position) == cell:
			return(node)


func request_move(pawn, direction):
	var cell_start = local_to_map(pawn.position)
	var cell_target = cell_start + direction

	#TODO
#	var cell_tile_id = get_cellv(cell_target)
#	match cell_tile_id:
#		-1:
#			set_cellv(cell_target, CellType.ACTOR)
#			set_cellv(cell_start, -1)
#			return map_to_local(cell_target) + cell_size / 2
#		CellType.OBJECT, CellType.ACTOR:
#			var target_pawn = get_cell_pawn(cell_target, cell_tile_id)
#			print("Cell %s contains %s" % [cell_target, target_pawn.name])
#
#			if not target_pawn.has_node("DialoguePlayer"):
#				return
#			get_node(dialogue_ui).show_dialogue(pawn, target_pawn.get_node(^"DialoguePlayer"))
