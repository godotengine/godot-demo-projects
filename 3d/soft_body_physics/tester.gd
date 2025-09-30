extends WorldEnvironment

const ROT_SPEED: float = 0.003
const ZOOM_SPEED: float = 0.125
const MAIN_BUTTONS: int = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

## The maximum number of additional cloths and boxes that can be spawned at a given time
## (for performance reasons).
const MAX_ADDITIONAL_ITEMS: int = 10

const Cloth: PackedScene = preload("res://cloth.tscn")
const RigidBoxLight: PackedScene = preload("res://rigid_box_light.tscn")
const RigidBoxHeavy: PackedScene = preload("res://rigid_box_heavy.tscn")
const Box: PackedScene = preload("res://box.tscn")
const Sphere: PackedScene = preload("res://sphere.tscn")

var tester_index: int = 0
var rot_x: float = deg_to_rad(-22.5)  # This must be kept in sync with RotationX.
var rot_y: float = deg_to_rad(90.0)  # This must be kept in sync with CameraHolder.
var zoom: float = 1.5
var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

var additional_items: Array[Node3D] = []

@onready var testers: Node3D = $Testers
@onready var camera_holder: Node3D = $CameraHolder  # Has a position and rotates on Y.
@onready var rotation_x: Node3D = $CameraHolder/RotationX
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D

@onready var nodes_to_reset: Array[SoftBody3D] = [
	$Testers/ClothPhysics/Cloth,
	$Testers/SoftBoxes/Box,
	$Testers/SoftBoxes/Box2,
	$Testers/SoftSpheres/Sphere,
	$Testers/SoftSpheres/Sphere2,
	$Testers/CentralImpulseTimer/Cloth,
	$Testers/PerPointImpulseTimer/Cloth,
	$Testers/CentralForceWind/Cloth,
	$Testers/PinnedPoints/PinnedCloth,
]

@onready var nodes_to_reset_types: Array[PackedScene] = [
	Cloth,
	Box,
	Box,
	Sphere,
	Sphere,
	Cloth,
	Cloth,
	Cloth,
	Cloth,
]

@onready var nodes_to_reset_global_positions: PackedVector3Array


func _ready() -> void:
	for node: Node3D in nodes_to_reset:
		nodes_to_reset_global_positions.push_back(node.global_position)

	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if event.is_action_pressed(&"reset_physics_simulation"):
		# Remove all additional (player-spawned) items.
		for additional_item in additional_items:
			additional_item.queue_free()

		additional_items.clear()

		# Reset everything to its base state by removing existing nodes and reinstancing new scenes to replace them.
		for idx in nodes_to_reset.size():
			var previous_name: String = nodes_to_reset[idx].name
			var previous_parent: Node = nodes_to_reset[idx].get_parent()
			nodes_to_reset[idx].queue_free()
			nodes_to_reset[idx] = nodes_to_reset_types[idx].instantiate()
			previous_parent.add_child(nodes_to_reset[idx])
			nodes_to_reset[idx].name = previous_name
			nodes_to_reset[idx].global_position = nodes_to_reset_global_positions[idx]
			if "PinnedCloth" in nodes_to_reset[idx].name:
				# Pin the four corners of the cloth.
				# These vertex IDs are valid with the PlaneMesh subdivision level set to 63 on both axes.
				for point: int in [0, 64, 4160, 4224]:
					nodes_to_reset[idx].set_point_pinned(point, true)

	if (
			event.is_action_pressed(&"place_cloth") or
			event.is_action_pressed(&"place_light_box") or
			event.is_action_pressed(&"place_heavy_box")
	):
		# Place a new item and track it in an additional items array, so we can limit
		# the number of player-spawned items present in the scene at a given time.
		var origin: Vector3 = camera.global_position
		var target: Vector3 = camera.project_position(get_viewport().get_mouse_position(), 100)

		var query := PhysicsRayQueryParameters3D.create(origin, target)
		# Ignore layer 2 which contains invisible walls.
		query.collision_mask = 1
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			if additional_items.size() >= MAX_ADDITIONAL_ITEMS:
				additional_items.pop_front().queue_free()

			var node: Node3D
			if event.is_action_pressed(&"place_cloth"):
				node = Cloth.instantiate()
				# Make user-placed cloth translucent to distinguish from the scene's own cloths.
				node.transparency = 0.35
			elif event.is_action_pressed(&"place_light_box"):
				node = RigidBoxLight.instantiate()
			else:
				node = RigidBoxHeavy.instantiate()

			node.position = result["position"] + Vector3(0, 0.5, 0)
			add_child(node)
			additional_items.push_back(node)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 1.5, 4)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, deg_to_rad(-90), 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# This code assumes CameraHolder's X and Y coordinates are already correct.
	var current_position_z: float = camera_holder.global_transform.origin.z
	var target_position_z: float = current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position_z, target_position_z, 3 * delta)
	camera.position.z = lerpf(camera.position.z, zoom, 10 * delta)


func _physics_process(delta: float) -> void:
	# Strong sideways wind force, which pushes the cloth while airborne and
	# makes it wave around once it has landed.
	const WIND_FORCE: float = 2_450_000.0
	for node in $Testers/CentralForceWind.get_children():
		if node is SoftBody3D:
			node.apply_central_force(Vector3(1.0, 0.0, 0.0) * WIND_FORCE * delta)

	# Use a loop to determine the right node to follow
	# (we need to do this as the node will have a different name after resetting).
	for cloth in $Testers/PerPointImpulseTimer.get_children():
		if cloth is SoftBody3D:
			for node in $Testers/PerPointImpulseTimer/PointTrackers.get_children():
				# Make the point trackers follow specific points stored in node metadata.
				# This can be used to make any node type (such as particles, a mesh, or even a rigid body)
				# follow a point. It's also possible to average the position of several points
				# to make an object follow an edge or a face in a best-effort manner.
				#
				# We slightly shift the tracker upwards to account for the cloth's thickness
				# (specified in the cloth material's Grow property).
				node.global_position = cloth.get_point_transform(node.get_meta(&"point")) + Vector3(0.0, 0.01, 0.0)


func _on_previous_pressed() -> void:
	tester_index = max(0, tester_index - 1)
	update_gui()


func _on_next_pressed() -> void:
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


func update_gui() -> void:
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


func _on_central_impulse_timer_timeout() -> void:
	# When using `apply_central_impulse()` instead of `apply_impulse()`,
	# we have to use a much larger value to get significant movement as the impulse is distributed
	# across all points.
	const INTENSITY: float = 8000.0

	for node in $Testers/CentralImpulseTimer.get_children():
		if node is SoftBody3D:
			var random_unit_vector := Vector3(randf_range(-1.0, 1.0), randf_range(-0.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			node.apply_central_impulse(random_unit_vector * INTENSITY)


func _on_per_point_impulse_timer_timeout() -> void:
	const INTENSITY: float = 600.0

	for node in $Testers/PerPointImpulseTimer.get_children():
		if node is SoftBody3D:
			# Apply impulse on the four corners of the cloth.
			# These vertex IDs are valid with the PlaneMesh subdivision level set to 63 on both axes.
			for point: int in [0, 64, 4160, 4224]:
				var random_unit_vector := Vector3(randf_range(-1.0, 1.0), randf_range(-0.0, 1.0), randf_range(-1.0, 1.0)).normalized()
				node.apply_impulse(point, random_unit_vector * INTENSITY)
