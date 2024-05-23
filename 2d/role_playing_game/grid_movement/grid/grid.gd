extends TileMap

enum CellType {
	ACTOR,
	OBSTACLE,
	OBJECT,
}

@export var dialogue_ui: Node

func _ready() -> void:
	for child in get_children():
		set_cell(0, local_to_map(child.position), child.type, Vector2i.ZERO)


func get_cell_pawn(cell: Vector2i, type: CellType = CellType.ACTOR) -> Node2D:
	for node in get_children():
		if node.type != type:
			continue
		if local_to_map(node.position) == cell:
			return node

	return null


func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell_start := local_to_map(pawn.position)
	var cell_target := cell_start + direction

	var cell_tile_id := get_cell_source_id(0, cell_target)
	match cell_tile_id:
		-1:
			set_cell(0, cell_target, CellType.ACTOR, Vector2i.ZERO)
			set_cell(0, cell_start, -1, Vector2i.ZERO)
			return map_to_local(cell_target)
		CellType.OBJECT, CellType.ACTOR:
			var target_pawn := get_cell_pawn(cell_target, cell_tile_id)
			#print("Cell %s contains %s" % [cell_target, target_pawn.name])

			if not target_pawn.has_node("DialoguePlayer"):
				return Vector2i.ZERO

			dialogue_ui.show_dialogue(pawn, target_pawn.get_node("DialoguePlayer"))

	return Vector2i.ZERO
