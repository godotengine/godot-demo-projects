extends Area3D


var taken = false


func _on_coin_body_enter(body):
	if not taken and body is Player:
		$Animation.play(&"take")
		taken = true
