extends Control

onready var tree = get_tree()

onready var crosshair = $Crosshair
onready var pause = $Pause
onready var options = $Options
onready var voxel_world = $"../VoxelWorld"


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause.visible = crosshair.visible
		crosshair.visible = !crosshair.visible
		options.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if crosshair.visible else Input.MOUSE_MODE_VISIBLE)


func _on_Resume_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crosshair.visible = true
	pause.visible = false


func _on_Options_pressed():
	options.prev_menu = pause
	options.visible = true
	pause.visible = false


func _on_MainMenu_pressed():
	voxel_world.clean_up()
	tree.change_scene("res://menu/main/main_menu.tscn")


func _on_Exit_pressed():
	voxel_world.clean_up()
	tree.quit()
