extends Node

func _on_body_entered(body):
	if body.name == "Player":
		$"../WinText".show()
