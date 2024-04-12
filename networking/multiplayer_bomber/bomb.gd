extends Area2D

var in_area: Array = []
var from_player: int

# Called from the animation.
func explode():
	if not is_multiplayer_authority():
		# Explode only on authority.
		return
	for p in in_area:
		if p.has_method("exploded"):
			# Checks if there is wall in between bomb and the object
			var world_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(position, p.position)
			query.hit_from_inside = true
			var result: Dictionary  = world_state.intersect_ray(query)
			if not result.collider is TileMap:
				# Exploded can only be called by the authority, but will also be called locally.
				p.exploded.rpc(from_player)


func done():
	if is_multiplayer_authority():
		queue_free()


func _on_bomb_body_enter(body):
	if not body in in_area:
		in_area.append(body)


func _on_bomb_body_exit(body):
	in_area.erase(body)
