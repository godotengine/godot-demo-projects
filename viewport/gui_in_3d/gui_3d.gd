extends Spatial

# Member variables
# The size of the quad mesh itself.
# NOTE: Do not apply the scale of the MeshInstance node, just the scale of the quad mesh!
export (Vector2) var quad_mesh_size = Vector2(3, 2)
# The scale of the quad node. It is assumed that the node is scaled evenly across the X, Y, and Z axes.
export (float) var quad_node_scale = 1
# The position of the last processed input touch/mouse event.
var prev_pos = null
# The last non-empty click_pos position. We need this to simulate drag events.
var last_click_pos = null
# The viewport we want to interact with.
var viewport = null
# A empty Vector3 used for comparison.
var empty_vector = Vector3(0,0,0)


func _input(event):
	# Check if the event is a non-mouse/non-touch event
	var is_mouse_event = false
	var mouse_events = [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]
	for mouse_event in mouse_events:
		if event is mouse_event:
			is_mouse_event = true
			break
  
	# If the event is not a mouse/touch event, then pass the event to the viewport as we do not
	# need to do any conversions for these events.
	if is_mouse_event == false:
		viewport.input(event)


# Mouse events for Area
func _on_area_input_event(camera, event, click_pos, click_normal, shape_idx):
	# If click_pos is not empty, then we want to store it so we can use it to simulate drag events.
	if click_pos != empty_vector:
		last_click_pos = click_pos
	
	var pos
	if click_pos == empty_vector:
		# Convert the last known click pos, last_click_pos, from world coordinate space to a coordinate space
		# relative to the Area node.
		# NOTE: affine_inverse accounts for the Area node's scale, rotation, and translation in the scene!
		pos = get_node("Area").global_transform.affine_inverse()*last_click_pos
		
		# If the event is has some form of dragging, then we need to simulate that drag in code.
		# NOTE: this is not a perfect solution, but it works okay.
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			pos.x += event.relative.x / viewport.size.x
			pos.y -= event.relative.y / viewport.size.y
		
		# Update last_click_pos with the newest version of pos, with adjustments for quad size.
		last_click_pos = pos * quad_node_scale
		
	else:
		# Convert click_pos from world coordinate space to a coordinate space relative to the Area node.
		# NOTE: affine_inverse accounts for the Area node's scale, rotation, and translation in the scene!
		pos = get_node("Area").global_transform.affine_inverse()*click_pos
	
	# convert the relative event position from 3D to 2D
	pos = Vector2(pos.x, -pos.y)
	
	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	pos.x += quad_mesh_size.x/2
	pos.y += quad_mesh_size.y/2
	# Then we need to convert it into the following range: 0 -> 1
	pos.x = pos.x/quad_mesh_size.x
	pos.y = pos.y/quad_mesh_size.y
	# Finally, we convert the position to the following range: 0 -> viewport.size
	pos.x = pos.x * viewport.size.x
	pos.y = pos.y * viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.
	
	# Set the event's position and global position.
	event.position = pos
	event.global_position = pos
	
	# If the event is a mouse motion event...
	if event is InputEventMouseMotion:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if prev_pos == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos
		else:
			event.relative = pos - prev_pos
	
	# Update prev_pos with the position we just calculated.
	prev_pos = pos
	
	# Finally, send the processed input event to the viewport.
	viewport.input(event)


func _ready():
	# Get the Viewport node and assign it to viewport for later use.
	viewport = get_node("Viewport")
	# Connect the input_event signal to the _on_area_input_event function.
	get_node("Area").connect("input_event", self, "_on_area_input_event")
  
