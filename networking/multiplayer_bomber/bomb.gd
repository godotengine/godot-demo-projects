extends Area2D

var in_area = []
var from_player

# Called from the animation.
func explode():
	if not is_multiplayer_authority():
		# Explode only on authority.
		return
	for p in in_area:
		if p.has_method("exploded"):
			# Exploded can only be called by the authority, but will also be called locally.
			p.rpc(&"exploded", from_player)


func done():
	if is_multiplayer_authority():
		queue_free()


func _on_bomb_body_enter(body):
	if not body in in_area:
		in_area.append(body)


func _on_bomb_body_exit(body):
	in_area.erase(body)
