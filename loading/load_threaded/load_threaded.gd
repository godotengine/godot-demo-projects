extends VBoxContainer


func _on_start_loading_pressed():
	ResourceLoader.load_threaded_request("res://paintings/painting_babel.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_las_meninas.png")
	ResourceLoader.load_threaded_request("res://paintings/painting_mona_lisa.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_old_guitarist.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_parasol.jpg")
	ResourceLoader.load_threaded_request("res://paintings/painting_the_swing.jpg")
	for current_button in $GetLoaded.get_children():
		current_button.disabled = false


func _on_babel_pressed():
	$Paintings/Babel.texture = ResourceLoader.load_threaded_get("res://paintings/painting_babel.jpg")
	$GetLoaded/Babel.disabled = true


func _on_las_meninas_pressed():
	$Paintings/LasMeninas.texture = ResourceLoader.load_threaded_get("res://paintings/painting_las_meninas.png")
	$GetLoaded/LasMeninas.disabled = true


func _on_mona_lisa_pressed():
	$Paintings/MonaLisa.texture = ResourceLoader.load_threaded_get("res://paintings/painting_mona_lisa.jpg")
	$GetLoaded/MonaLisa.disabled = true


func _on_old_guitarist_pressed():
	$Paintings/OldGuitarist.texture = ResourceLoader.load_threaded_get("res://paintings/painting_old_guitarist.jpg")
	$GetLoaded/OldGuitarist.disabled = true


func _on_parasol_pressed():
	$Paintings/Parasol.texture = ResourceLoader.load_threaded_get("res://paintings/painting_parasol.jpg")
	$GetLoaded/Parasol.disabled = true


func _on_swing_pressed():
	$Paintings/Swing.texture = ResourceLoader.load_threaded_get("res://paintings/painting_the_swing.jpg")
	$GetLoaded/Swing.disabled = true
