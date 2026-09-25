extends Control

@onready var vp_orig = $HBoxContainer/VBoxContainer/SubViewportContainer/ViewOrig
@onready var vp_a = $HBoxContainer/VBoxContainer2/SubViewportContainer/ViewA
@onready var vp_b = $HBoxContainer/VBoxContainer3/SubViewportContainer/ViewB
@onready var no_scene_lbl = $NoNodeLbl

@export_file("*.pck") var pck_1
@export_file("*.pck") var pck_2
@export_file("*.pck") var pck_3


func _ready():
	reload_scene()


func reload_scene():
	$LineEdit.text = ""
	populate_file_list("res://")

	load_scene_at_node("res://orig.tscn", vp_orig)
	load_scene_at_node("res://a.tscn", vp_a)
	load_scene_at_node("res://b.tscn", vp_b)


func populate_file_list(path: String):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			populate_file_list(path + file_name + "/")
		else:
			$LineEdit.text += path + file_name + '\n'
		file_name = dir.get_next()


func load_scene_at_node(scene_name: String, node: Node):
	var child
	if ResourceLoader.exists(scene_name):
		child = load(scene_name).instantiate()
	else:
		child = no_scene_lbl.duplicate()
		child.position = Vector2.ZERO
	if node.get_child_count() > 0:
		node.remove_child(node.get_child(0))
	node.add_child(child)


func _on_load1_pressed():
	ProjectSettings.load_resource_pack(pck_1, $VBoxContainer/HBoxContainer/CheckBox.is_pressed())
	reload_scene()


func _on_unload1_pressed():
	ProjectSettings.unload_resource_pack(pck_1)
	reload_scene()


func _on_load2_pressed():
	ProjectSettings.load_resource_pack(pck_2, $VBoxContainer/HBoxContainer2/CheckBox.is_pressed())
	reload_scene()


func _on_unload2_pressed():
	ProjectSettings.unload_resource_pack(pck_2)
	reload_scene()


func _on_load3_pressed():
	ProjectSettings.load_resource_pack(pck_3, $VBoxContainer/HBoxContainer3/CheckBox.is_pressed())
	reload_scene()


func _on_unload3_pressed():
	ProjectSettings.unload_resource_pack(pck_3)
	reload_scene()
