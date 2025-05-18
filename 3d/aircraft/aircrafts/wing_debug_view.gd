extends Node3D
class_name WingDebugView

@export var wing_material: Material
@export var control_surface_material: Material
@export var warning_material: Material
@export var stall_material: Material

@onready var wing := get_parent() as VehicleWing3D

class Section:
	var view: CSGBox3D
	var control_surface_node: Node3D
	var control_surface_view: CSGBox3D
	var index: int

var sections: Array[Section]


func _ready() -> void:
	build()


func _process(_delta: float) -> void:
	update_sections()


func build() -> void:
	clear()
	if wing == null:
		return
	for i in wing.get_section_count():
		var section := Section.new()
		sections.append(section)
		section.index = i
		section.view = CSGBox3D.new()
		var chord := wing.get_section_chord(i)
		var control_surface_chord := chord * wing.get_section_control_surface_fraction(i)
		var section_transform := wing.get_section_transform(i)
		chord -= control_surface_chord
		section.view.material = wing_material
		section.view.basis = section_transform.basis
		section.view.position = section_transform.origin + Vector3.FORWARD * control_surface_chord * 0.5 + Vector3.BACK * (wing.get_mac() * 0.25)
		section.view.size.x = wing.get_section_length(i) * 0.95
		section.view.size.y = chord * 0.05
		section.view.size.z = chord
		add_child(section.view)
		if control_surface_chord > 0.0:
			section.control_surface_node = Node3D.new()
			section.control_surface_node.position.z = chord * 0.5
			section.view.add_child(section.control_surface_node)
			section.control_surface_view = CSGBox3D.new()
			section.control_surface_view.material = control_surface_material
			section.control_surface_view.size = Vector3(section.view.size.x, section.view.size.y * 0.75, control_surface_chord)
			section.control_surface_view.position.z = control_surface_chord * 0.5
			section.control_surface_node.add_child(section.control_surface_view)


func clear() -> void:
	sections.clear()
	for i in get_child_count():
		get_child(i).queue_free()


func update_sections() -> void:
	if wing == null:
		return
	for i in mini(wing.get_section_count(), len(sections)):
		var section := sections[i]
		var material := get_wing_material(i)
		if section.view.material != material:
			section.view.material = material
		if section.control_surface_node == null or section.control_surface_view == null:
			continue
		material = get_control_surface_material(i)
		if section.control_surface_view.material != material:
			section.control_surface_view.material = material
		section.control_surface_node.rotation.x = wing.get_section_control_surface_angle(i)


func get_wing_material(index: int) -> Material:
	if wing.is_section_stall(index):
		return stall_material
	if wing.is_section_stall_warning(index):
		return warning_material
	return wing_material


func get_control_surface_material(index: int) -> Material:
	if wing.is_section_stall(index):
		return stall_material
	return control_surface_material
