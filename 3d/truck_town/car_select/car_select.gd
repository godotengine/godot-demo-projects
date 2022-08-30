extends Control

var town: Node3D = null

func _process(_delta: float):
	if Input.is_action_just_pressed(&"back"):
		_on_back_pressed()


func _load_scene(car_path: String):
	var car: Node3D = load(car_path).instantiate()
	car.name = &"car"
	town = load("res://town/town_scene.tscn").instantiate()
	town.get_node(^"InstancePos").add_child(car)
	town.get_node(^"Spedometer").car_body = car.get_child(0)
	town.get_node(^"Back").pressed.connect(_on_back_pressed)

	get_parent().add_child(town)
	hide()


func _on_back_pressed():
	if is_instance_valid(town):
		# Currently in the town, go back to main menu.
		town.queue_free()
		show()
	else:
		# In main menu, exit the game.
		get_tree().quit()


func _on_mini_van_pressed():
	_load_scene("res://vehicles/car_base.tscn")


func _on_trailer_truck_pressed():
	_load_scene("res://vehicles/trailer_truck.tscn")


func _on_tow_truck_pressed():
	_load_scene("res://vehicles/tow_truck.tscn")
