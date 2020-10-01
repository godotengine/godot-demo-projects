tool
extends Spatial

export(NodePath) var skeleton_path setget _set_skeleton_path
export(String) var bone_name = ""
export(int, "_process", "_physics_process", "_notification", "none") var update_mode = 0 setget _set_update
export(int, "X-up", "Y-up", "Z-up") var look_at_axis = 1
export(bool) var use_our_rotation_x = false
export(bool) var use_our_rotation_y = false
export(bool) var use_our_rotation_z = false
export(bool) var use_negative_our_rot = false
export(Vector3) var additional_rotation = Vector3()
export(bool) var position_using_additional_bone = false
export(String) var additional_bone_name = ""
export(float) var additional_bone_length = 1
export(bool) var debug_messages = false

var skeleton_to_use: Skeleton = null
var first_call: bool = true
var _editor_indicator: Spatial = null


func _ready():
	set_process(false)
	set_physics_process(false)
	set_notify_transform(false)

	if update_mode == 0:
		set_process(true)
	elif update_mode == 1:
		set_physics_process(true)
	elif update_mode == 2:
		set_notify_transform(true)
	else:
		if debug_messages:
			print(name, " - IK_LookAt: Unknown update mode. NOT updating skeleton")

	if Engine.editor_hint:
		_setup_for_editor()


func _process(_delta):
	update_skeleton()


func _physics_process(_delta):
	update_skeleton()


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_skeleton()


func update_skeleton():
	# NOTE: Because get_node doesn't work in _ready, we need to skip
	# a call before doing anything.
	if first_call:
		first_call = false
		if skeleton_to_use == null:
			_set_skeleton_path(skeleton_path)


	# If we do not have a skeleton and/or we're not supposed to update, then return.
	if skeleton_to_use == null:
		return
	if update_mode >= 3:
		return

	# Get the bone index.
	var bone: int = skeleton_to_use.find_bone(bone_name)

	# If no bone is found (-1), then return and optionally printan error.
	if bone == -1:
		if debug_messages:
			print(name, " - IK_LookAt: No bone in skeleton found with name [", bone_name, "]!")
		return

	# get the bone's global transform pose.
	var rest = skeleton_to_use.get_bone_global_pose(bone)

	# Convert our position relative to the skeleton's transform.
	var target_pos = skeleton_to_use.global_transform.xform_inv(global_transform.origin)

	# Call helper's look_at function with the chosen up axis.
	if look_at_axis == 0:
		rest = rest.looking_at(target_pos, Vector3.RIGHT)
	elif look_at_axis == 1:
		rest = rest.looking_at(target_pos, Vector3.UP)
	elif look_at_axis == 2:
		rest = rest.looking_at(target_pos, Vector3.FORWARD)
	else:
		rest = rest.looking_at(target_pos, Vector3.UP)
		if debug_messages:
			print(name, " - IK_LookAt: Unknown look_at_axis value!")

	# Get the rotation euler of the bone and of this node.
	var rest_euler = rest.basis.get_euler()
	var self_euler = global_transform.basis.orthonormalized().get_euler()

	# Flip the rotation euler if using negative rotation.
	if use_negative_our_rot:
		self_euler = -self_euler

	# Apply this node's rotation euler on each axis, if wanted/required.
	if use_our_rotation_x:
		rest_euler.x = self_euler.x
	if use_our_rotation_y:
		rest_euler.y = self_euler.y
	if use_our_rotation_z:
		rest_euler.z = self_euler.z

	# Make a new basis with the, potentially, changed euler angles.
	rest.basis = Basis(rest_euler)

	# Apply additional rotation stored in additional_rotation to the bone.
	if additional_rotation != Vector3.ZERO:
		rest.basis = rest.basis.rotated(rest.basis.x, deg2rad(additional_rotation.x))
		rest.basis = rest.basis.rotated(rest.basis.y, deg2rad(additional_rotation.y))
		rest.basis = rest.basis.rotated(rest.basis.z, deg2rad(additional_rotation.z))

	# If the position is set using an additional bone, then set the origin
	# based on that bone and its length.
	if position_using_additional_bone:
		var additional_bone_id = skeleton_to_use.find_bone(additional_bone_name)
		var additional_bone_pos = skeleton_to_use.get_bone_global_pose(additional_bone_id)
		rest.origin = additional_bone_pos.origin - additional_bone_pos.basis.z.normalized() * additional_bone_length

	# Finally, apply the new rotation to the bone in the skeleton.
	skeleton_to_use.set_bone_global_pose_override(bone, rest, 1.0, true)


func _setup_for_editor():
	# To see the target in the editor, let's create a MeshInstance,
	# add it as a child of this node, and name it.
	_editor_indicator = MeshInstance.new()
	add_child(_editor_indicator)
	_editor_indicator.name = "(EditorOnly) Visual indicator"

	# Make a sphere mesh for the MeshInstance
	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = 0.1
	indicator_mesh.height = 0.2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4

	# Create a new SpatialMaterial for the sphere and give it the editor
	# gizmo texture so it is textured.
	var indicator_material = SpatialMaterial.new()
	indicator_material.flags_unshaded = true
	indicator_material.albedo_texture = preload("editor_gizmo_texture.png")
	indicator_material.albedo_color = Color(1, 0.5, 0, 1)

	# Assign the material and mesh to the MeshInstance.
	indicator_mesh.material = indicator_material
	_editor_indicator.mesh = indicator_mesh


func _set_update(new_value):
	update_mode = new_value

	# Set all of our processes to false.
	set_process(false)
	set_physics_process(false)
	set_notify_transform(false)

	# Based on the value of passed to update, enable the correct process.
	if update_mode == 0:
		set_process(true)
		if debug_messages:
			print(name, " - IK_LookAt: updating skeleton using _process...")
	elif update_mode == 1:
		set_physics_process(true)
		if debug_messages:
			print(name, " - IK_LookAt: updating skeleton using _physics_process...")
	elif update_mode == 2:
		set_notify_transform(true)
		if debug_messages:
			print(name, " - IK_LookAt: updating skeleton using _notification...")
	else:
		if debug_messages:
			print(name, " - IK_LookAt: NOT updating skeleton due to unknown update method...")


func _set_skeleton_path(new_value):
	# Because get_node doesn't work in the first call, we just want to assign instead.
	# This is to get around a issue with NodePaths exposed to the editor.
	if first_call:
		skeleton_path = new_value
		return

	# Assign skeleton_path to whatever value is passed.
	skeleton_path = new_value

	if skeleton_path == null:
		if debug_messages:
			print(name, " - IK_LookAt: No Nodepath selected for skeleton_path!")
		return

	# Get the node at that location, if there is one.
	var temp = get_node(skeleton_path)
	if temp != null:
		if temp is Skeleton:
			skeleton_to_use = temp
			if debug_messages:
				print(name, " - IK_LookAt: attached to (new) skeleton")
		else:
			skeleton_to_use = null
			if debug_messages:
				print(name, " - IK_LookAt: skeleton_path does not point to a skeleton!")
	else:
		if debug_messages:
			print(name, " - IK_LookAt: No Nodepath selected for skeleton_path!")
