tool
extends Spatial

export (NodePath) var skeleton_path setget _set_skeleton_path
export (String) var bone_name = ""
export (int, "_process", "_physics_process", "_notification", "none") var update_mode = 0 setget _set_update
export (int, "X-up", "Y-up", "Z-up") var look_at_axis = 1
export (bool) var use_our_rotation_x = false
export (bool) var use_our_rotation_y = false
export (bool) var use_our_rotation_z = false
export (bool) var use_negative_our_rot = false
export (Vector3) var additional_rotation = Vector3()
export (bool) var debug_messages = false

var skeleton_to_use
var first_call = true
const empty_vector = Vector3()

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
		if debug_messages == true:
			print (name, " - IK_LookAt: Unknown update mode. NOT updating skeleton")
	
	if Engine.editor_hint == true:
		_setup_for_editor()


func _setup_for_editor():
	# So we can see the target in the editor, let's create a mesh instance,
	# Add it as our child, and name it
	var indicator = MeshInstance.new()
	add_child(indicator)
	indicator.name = "(EditorOnly) Visual indicator"

	# We need to make a mesh for the mesh instance.
	# The code below makes a small sphere mesh
	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = 0.1
	indicator_mesh.height = 0.2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4

	# The mesh needs a material (unless we want to use the defualt one).
	# Let's create a material and use the EditorGizmoTexture to texture it.
	var indicator_material = SpatialMaterial.new()
	indicator_material.flags_unshaded = true
	indicator_material.albedo_texture = preload("editor_gizmo_texture.png")
	indicator_material.albedo_color = Color(1, 0.5, 0, 1)
	indicator_mesh.material = indicator_material
	indicator.mesh = indicator_mesh


func _set_update(new_value):
	update_mode = new_value
	
	# Set all of our processes to false
	set_process(false)
	set_physics_process(false)
	set_notify_transform(false)
	
	# Based on the value of upate, change how we handle updating the skeleton
	if update_mode == 0:
		set_process(true)
		if debug_messages == true:
			print (name, " - IK_LookAt: updating skeleton using _process...")
	elif update_mode == 1:
		set_physics_process(true)
		if debug_messages == true:
			print (name, " - IK_LookAt: updating skeleton using _physics_process...")
	elif update_mode == 2:
		set_notify_transform(true)
		if debug_messages == true:
			print (name, " - IK_LookAt: updating skeleton using _notification...")
	else:
		if debug_messages == true:
			print (name, " - IK_LookAt: NOT updating skeleton due to unknown update method...")


func _set_skeleton_path(new_value):
	
	# Because get_node doesn't work in the first call, we just want to assign instead
	# This is to get around a issue with NodePaths exposed to the editor
	if first_call == true:
		skeleton_path = new_value
		return
	
	# Assign skeleton_path to whatever value is passed
	skeleton_path = new_value
	
	if skeleton_path == null:
		if debug_messages == true:
			print (name, " - IK_LookAt: No Nodepath selected for skeleton_path!")
		return
	
	# Get the node at that location, if there is one
	var temp = get_node(skeleton_path)
	if temp != null:
		# If the node has the method "find_bone" then we can assume it is (likely) a skeleton
		if temp.has_method("find_bone") == true:
			skeleton_to_use = temp
			if debug_messages == true:
				print (name, " - IK_LookAt: attached to (new) skeleton")
		# If not, then it's (likely) not a skeleton
		else:
			skeleton_to_use = null
			if debug_messages == true:
				print (name, " - IK_LookAt: skeleton_path does not point to a skeleton!")
	else:
		if debug_messages == true:
			print (name, " - IK_LookAt: No Nodepath selected for skeleton_path!")


func update_skeleton():
	
	# NOTE: Because get_node doesn't work in _ready, we need to skip
	# a call before doing anything.
	if first_call == true:
		first_call = false
		if skeleton_to_use == null:
			_set_skeleton_path(skeleton_path)
	
	
	# If we do not have a skeleton and/or we're not supposed to update, then return.
	if skeleton_to_use == null:
		return
	if update_mode >= 3:
		return
	
	# Get the bone
	var bone = skeleton_to_use.find_bone(bone_name)
	
	# If no bone is found (-1), then return (and optionally print an error)
	if bone == -1:
		if debug_messages == true:
			print (name, " - IK_LookAt: No bone in skeleton found with name [", bone_name, "]!")
		return
	
	# get the bone's rest position, and our position
	var rest = skeleton_to_use.get_bone_global_pose(bone)
	var our_position = global_transform.origin
	
	# Convert our position relative to the skeleton's transform
	var target_pos = skeleton_to_use.global_transform.xform_inv(global_transform.origin)
	
	# Call helper's look_at function with the chosen up axis.
	if look_at_axis == 0:
		rest = rest.looking_at(target_pos, Vector3(1, 0, 0))
	elif look_at_axis == 1:
		rest = rest.looking_at(target_pos, Vector3(0, 1, 0))
	elif look_at_axis == 2:
		rest = rest.looking_at(target_pos, Vector3(0, 0, 1))
	else:
		rest = rest.looking_at(target_pos, Vector3(0, 1, 0))
		if debug_messages == true:
			print (name, " - IK_LookAt: Unknown look_at_axis value!")
	
	# Get our rotation euler, and the bone's rotation euler
	var rest_euler = rest.basis.get_euler()
	var self_euler = global_transform.basis.orthonormalized().get_euler()
	
	# If we using negative rotation, we flip our rotation euler
	if use_negative_our_rot == true:
		self_euler = -self_euler
	
	# Apply our rotation euler, if wanted/required
	if use_our_rotation_x == true:
		rest_euler.x = self_euler.x
	if use_our_rotation_y == true:
		rest_euler.y = self_euler.y
	if use_our_rotation_z == true:
		rest_euler.z = self_euler.z
	
	# Rotate the bone by the (potentially) changed euler angle(s)
	rest.basis = Basis(rest_euler)
	
	# If we have additional rotation, then rotate it by the local rotation vectors
	if additional_rotation != empty_vector:
		rest.basis = rest.basis.rotated(rest.basis.x, deg2rad(additional_rotation.x))
		rest.basis = rest.basis.rotated(rest.basis.y, deg2rad(additional_rotation.y))
		rest.basis = rest.basis.rotated(rest.basis.z, deg2rad(additional_rotation.z))
	
	# Finally, apply the bone rotation to the skeleton
	skeleton_to_use.set_bone_global_pose(bone, rest)


# Various upate methods
# ---------------------
func _process(delta):
	update_skeleton()
func _physics_process(delta):
	update_skeleton()
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_skeleton()