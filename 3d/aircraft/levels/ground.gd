@tool
extends MeshInstance3D
class_name Ground

@export var size := 1024.0
@export var chunk_count := 5
@export var road_width := 30.0
@export var ground_material: Material
@export var road_material: Material

var current_cell: Vector2i
var immediate_mesh: ImmediateMesh


func _ready() -> void:
	if mesh is not ImmediateMesh:
		mesh = ImmediateMesh.new()
	immediate_mesh = mesh as ImmediateMesh
	_generate_terrain(current_cell)


func set_target(target: Vector3) -> void:
	var half := size * 0.5
	var cell := Vector2i(floori((target.x + half) / size), floori((target.z + half) / size))
	if current_cell != cell:
		current_cell = cell
		_generate_terrain(cell)


func _generate_terrain(cell: Vector2i) -> void:
	if immediate_mesh == null:
		return
	immediate_mesh.clear_surfaces()
	for x in chunk_count * 2 + 1:
		for y in chunk_count * 2 + 1:
			var target_cell := cell + Vector2i(x - chunk_count, y - chunk_count)
			if target_cell == Vector2i.ZERO:
				_generate_road_cell(target_cell)
			else:
				_generate_ground_cell(target_cell)


func _generate_ground_cell(cell: Vector2i) -> void:
	var pos := cell * size
	var offset := -Vector2(size, size) * 0.5
	var begin := Vector2(pos.x, pos.y) + offset
	var end := Vector2(pos.x + size, pos.y + size) + offset
	_create_surface(begin, end, ground_material)


func _generate_road_cell(cell: Vector2i) -> void:
	var pos := cell * size
	var offset := -Vector2(size, size) * 0.5
	var width := road_width if size > road_width else size * 0.9
	var left := (pos.x + size - width) / 2
	var right := (pos.x + size + width) / 2
	_create_surface(Vector2(pos.x, pos.y) + offset, Vector2(pos.x + left, pos.y + size) + offset, ground_material)
	_create_surface(Vector2(pos.x + right, pos.y) + offset, Vector2(pos.x + size, pos.y + size) + offset, ground_material)
	_create_surface(Vector2(pos.x + left, pos.y) + offset, Vector2(pos.x + right, pos.y + size) + offset, road_material)


func _create_surface(begin: Vector2, end: Vector2, material: Material) -> void:
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	immediate_mesh.surface_set_normal(Vector3.UP)
	immediate_mesh.surface_set_uv(Vector2(0, 0))
	immediate_mesh.surface_add_vertex(Vector3(begin.x, 0, begin.y))
	immediate_mesh.surface_set_normal(Vector3.UP)
	immediate_mesh.surface_set_uv(Vector2(1, 0))
	immediate_mesh.surface_add_vertex(Vector3(end.x, 0, begin.y))
	immediate_mesh.surface_set_normal(Vector3.UP)
	immediate_mesh.surface_set_uv(Vector2(0, 1))
	immediate_mesh.surface_add_vertex(Vector3(begin.x, 0, end.y))
	immediate_mesh.surface_set_normal(Vector3.UP)
	immediate_mesh.surface_set_uv(Vector2(1, 1))
	immediate_mesh.surface_add_vertex(Vector3(end.x, 0, end.y))
	immediate_mesh.surface_end()
	immediate_mesh.surface_set_material(immediate_mesh.get_surface_count() - 1, material)
