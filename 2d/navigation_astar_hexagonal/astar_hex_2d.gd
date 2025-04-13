class_name AStarHex2D
extends AStar2D

var map: TileMap


# Final cost used for pathfinding would be weight * cost.
# See https://docs.godotengine.org/fr/4.x/classes/class_astar3d.html#class-astar3d
func _compute_cost(_from_id: int, _to_id: int):
	return 1


func _estimate_cost(_from_id: int, _to_id: int):
	return 1

# Euclidian distance heuristic would not work on hexagonal map with global position because
# we are not using regular hexagon.
# https://github.com/godotengine/godot/issues/92338

#func _compute_cost( from_id:int, to_id:int ):
#var position_from = get_point_position(from_id)
#var position_to = get_point_position(to_id)
#return (position_to - position_from).length_squared()

#func _estimate_cost( from_id:int, to_id:int ):
#var position_from = get_point_position(from_id)
#var position_to = get_point_position(to_id)
#return (position_to - position_from).length_squared()
