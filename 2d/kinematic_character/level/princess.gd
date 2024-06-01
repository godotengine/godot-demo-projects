extends Node

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$"../WinText".show()
