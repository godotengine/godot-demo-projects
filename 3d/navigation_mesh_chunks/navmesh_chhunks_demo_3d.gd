extends Node3D


static var map_cell_size: float = 0.25
static var chunk_size: int = 16
static var cell_size: float = 0.25
static var agent_radius: float = 0.5
static var chunk_id_to_region: Dictionary = {}


var path_start_position: Vector3


func _ready() -> void:
	NavigationServer3D.set_debug_enabled(true)

	path_start_position = %DebugPaths.global_position

	var map: RID = get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(map, map_cell_size)

	# Disable performance costly edge connection margin feature.
	# This feature is not needed to merge navigation mesh edges.
	# If edges are well aligned they will merge just fine by edge key.
	NavigationServer3D.map_set_use_edge_connections(map, false)

	# Parse the collision shapes below our parse root node.
	var source_geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	var parse_settings: NavigationMesh = NavigationMesh.new()
	parse_settings.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	NavigationServer3D.parse_source_geometry_data(parse_settings, source_geometry, %ParseRootNode)

	create_region_chunks(%ChunksContainer, source_geometry, chunk_size * cell_size, agent_radius)


static func create_region_chunks(chunks_root_node: Node, p_source_geometry: NavigationMeshSourceGeometryData3D, p_chunk_size: float, p_agent_radius: float) -> void:
	# We need to know how many chunks are required for the input geometry.
	# So first get an axis aligned bounding box that covers all vertices.
	var input_geometry_bounds: AABB = calculate_source_geometry_bounds(p_source_geometry)

	# Rasterize bounding box into chunk grid to know range of required chunks.
	var start_chunk: Vector3 = floor(
		input_geometry_bounds.position / p_chunk_size
	)
	var end_chunk: Vector3 = floor(
		(input_geometry_bounds.position + input_geometry_bounds.size)
		/ p_chunk_size
	)

	# NavigationMesh.border_size is limited to the xz-axis.
	# So we can only bake one chunk for the y-axis and also
	# need to span the bake bounds over the entire y-axis.
	# If we dont do this we would create duplicated polygons
	# and stack them on top of each other causing merge errors.
	var bounds_min_height: float = start_chunk.y
	var bounds_max_height: float = end_chunk.y + p_chunk_size
	var chunk_y: int = 0

	for chunk_z in range(start_chunk.z, end_chunk.z + 1):
		for chunk_x in range(start_chunk.x, end_chunk.x + 1):
			var chunk_id: Vector3i = Vector3i(chunk_x, chunk_y, chunk_z)

			var chunk_bounding_box: AABB = AABB(
				Vector3(chunk_x, bounds_min_height, chunk_z) * p_chunk_size,
				Vector3(p_chunk_size, bounds_max_height, p_chunk_size),
			)
			# We grow the chunk bounding box to include geometry
			# from all the neighbor chunks so edges can align.
			# The border size is the same value as our grow amount so
			# the final navigation mesh ends up with the intended chunk size.
			var baking_bounds: AABB = chunk_bounding_box.grow(p_chunk_size)

			var chunk_navmesh: NavigationMesh = NavigationMesh.new()
			chunk_navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
			chunk_navmesh.cell_size = cell_size
			chunk_navmesh.cell_height = cell_size
			chunk_navmesh.filter_baking_aabb = baking_bounds
			chunk_navmesh.border_size = p_chunk_size
			chunk_navmesh.agent_radius = p_agent_radius
			NavigationServer3D.bake_from_source_geometry_data(chunk_navmesh, p_source_geometry)

			# The only reason we reset the baking bounds here is to not render its debug.
			chunk_navmesh.filter_baking_aabb = AABB()

			# Snap vertex positions to avoid most rasterization issues with float precision.
			var navmesh_vertices: PackedVector3Array = chunk_navmesh.vertices
			for i in navmesh_vertices.size():
				var vertex: Vector3 = navmesh_vertices[i]
				navmesh_vertices[i] = vertex.snappedf(map_cell_size * 0.1)
			chunk_navmesh.vertices = navmesh_vertices

			var chunk_region: NavigationRegion3D = NavigationRegion3D.new()
			chunk_region.navigation_mesh = chunk_navmesh
			chunks_root_node.add_child(chunk_region)

			chunk_id_to_region[chunk_id] = chunk_region


static func calculate_source_geometry_bounds(p_source_geometry: NavigationMeshSourceGeometryData3D) -> AABB:
	if p_source_geometry.has_method("get_bounds"):
		# Godot 4.3 Patch added get_bounds() function that does the same but faster.
		return p_source_geometry.call("get_bounds")

	var bounds: AABB = AABB()
	var first_vertex: bool = true

	var vertices: PackedFloat32Array = p_source_geometry.get_vertices()
	var vertices_count: int = vertices.size() / 3
	for i in vertices_count:
		var vertex: Vector3 = Vector3(vertices[i * 3], vertices[i * 3 + 1], vertices[i * 3 + 2])
		if first_vertex:
			first_vertex = false
			bounds.position = vertex
		else:
			bounds = bounds.expand(vertex)

	for projected_obstruction: Dictionary in p_source_geometry.get_projected_obstructions():
		var projected_obstruction_vertices: PackedFloat32Array = projected_obstruction["vertices"]
		for i in projected_obstruction_vertices.size() / 3:
			var vertex: Vector3 = Vector3(projected_obstruction.vertices[i * 3], projected_obstruction.vertices[i * 3 + 1], projected_obstruction.vertices[i * 3 + 2]);
			if first_vertex:
				first_vertex = false
				bounds.position = vertex
			else:
				bounds = bounds.expand(vertex)

	return bounds


func _process(_delta: float) -> void:
	var mouse_cursor_position: Vector2 = get_viewport().get_mouse_position()

	var map: RID = get_world_3d().navigation_map
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	var camera_ray_length: float = 1000.0
	var camera_ray_start: Vector3 = camera.project_ray_origin(mouse_cursor_position)
	var camera_ray_end: Vector3 = camera_ray_start + camera.project_ray_normal(mouse_cursor_position) * camera_ray_length
	var closest_point_on_navmesh: Vector3 = NavigationServer3D.map_get_closest_point_to_segment(
		map,
		camera_ray_start,
		camera_ray_end
	)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		path_start_position = closest_point_on_navmesh

	%DebugPaths.global_position = path_start_position

	%PathDebugCorridorFunnel.target_position = closest_point_on_navmesh
	%PathDebugEdgeCentered.target_position = closest_point_on_navmesh

	%PathDebugCorridorFunnel.get_next_path_position()
	%PathDebugEdgeCentered.get_next_path_position()
