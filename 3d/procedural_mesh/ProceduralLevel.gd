extends Spatial

func _ready():
	# Get the Array with the information of the mesh
	var mesh_data = create_mesh_data(Vector2(0, 0), Vector2(10, 10))
	
	# Add the information to an ArrayMesh
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data);
	
	# Create mesh
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = arr_mesh
	
	# Set a material
	var material = load("res://terrain_material.tres")
	mesh_instance.set_surface_material(0, material)
	
	add_child(mesh_instance)
	
	# Create collisions
	var static_body = generate_collisions(mesh_data)
	add_child(static_body)

func create_mesh_data(var origin, var end):
	var arr = []
	arr.resize(ArrayMesh.ARRAY_MAX)
	
	# Vertices list to save the coordinates
	var vertices = PoolVector3Array()
	
	# Noise source, we use this to add get random heights
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 28
	
	var noise_multiplier = 8
	
	# Triangle creation
	# The following loop creates 2 triangles each iteration.
	# The vertex order is the following:
	#
	#  1_______2          1
	#  |     /          ∕ | 
	#  |   /          /   |
	#  | /          ∕     |
	#  0          2-------0
	#
	for x in range(origin.x, end.x):
		for y in range(origin.y, end.y):
			# next coords
			var n_x = x + 1
			var n_y = y + 1
			# heights
			var h_xy = noise.get_noise_2d(x, y) * noise_multiplier
			var h_nxy = noise.get_noise_2d(n_x, y) * noise_multiplier
			var h_xny = noise.get_noise_2d(x, n_y) * noise_multiplier
			var h_nxny = noise.get_noise_2d(n_x, n_y) * noise_multiplier
			# first triangle
			vertices.push_back(Vector3(x, h_xy, y));
			vertices.push_back(Vector3(n_x, h_nxy, y));
			vertices.push_back(Vector3(x, h_xny, n_y));
			
			# second triangle
			vertices.push_back(Vector3(n_x, h_nxy, y));
			vertices.push_back(Vector3(n_x, h_nxny, n_y));
			vertices.push_back(Vector3(x, h_xny, n_y));
	
	arr[ArrayMesh.ARRAY_VERTEX] = vertices
	
	return arr

func generate_collisions(var mesh_data):
	# We use a concave shape because our geometry might not be
	# properly represented by a convex shape.
	var shape = ConcavePolygonShape.new()
	shape.set_faces(mesh_data[ArrayMesh.ARRAY_VERTEX]);
	var body = StaticBody.new()
	var owner_id = body.create_shape_owner(body)
	body.shape_owner_add_shape(owner_id, shape)
	return body
