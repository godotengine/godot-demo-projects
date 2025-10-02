extends Area3D

var taken := false

func _on_coin_body_enter(body: Node) -> void:
	if not taken and body is Player:
		$Animation.play(&"take")
		taken = true
		# We've already checked whether the colliding body is a Player, which has a `coins` property.
		# As a result, we can safely increment its `coins` property.
		body.coins += 1
