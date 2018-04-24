tool
extends Spatial

"""
A FABRIK IK chain with a middle joint helper.
"""

export (NodePath) var skeleton_path setget _set_skeleton_path
export (PoolStringArray) var bones_in_chain setget _set_bone_chain_bones
export (PoolRealArray) var bones_in_chain_lengths setget _set_bone_chain_lengths

export (int, "_process", "_physics_process", "_notification", "none") var update_mode = 0 setget _set_update_mode

var target = null

var skeleton

# A dictionary holding all of the bone IDs (from the skeleton) and a dictionary holding
# all of the bone helper nodes
var bone_IDs = {}
var bone_nodes = {}

# The position of the origin
var chain_origin = null
# The combined length of every bone in the bone chain
var total_length = null
# The delta/tolerance for the bone chain (how do the bones need to be before it is considered satisfactory)
const CHAIN_TOLERANCE = 0.01
# The amount of interations the bone chain will go through in an attempt to get to the target position
const CHAIN_MAX_ITER = 10
# The amount of iterations we've been through, and whether or not we want to limit our solver to CHAIN_MAX_ITER
# amounts of interations.
export (int) var chain_iterations = 0
export (bool) var limit_chain_iterations = true
# Should we reset chain_iterations on movement during our update method?
export (bool) var reset_iterations_on_update = false

# A boolean to track whether or not we want to move the middle joint towards middle joint target.
export (bool) var use_middle_joint_target = false
var middle_joint_target = null

# Have we called _set_skeleton_path or not already. Due to some issues using exported NodePaths,
# we need to ignore the first _set_skeleton_path call.
var first_call = true

# A boolean to track whether or not we want to print debug messages
var debug_messages = false

func _ready():
	
	if (target == null):
		# NOTE: you HAVE to have a node called target as a child of this node!
		# so we create one if one doesn't already exist
		if has_node("target") == false:
			target = Spatial.new()
			add_child(target)
			
			if Engine.editor_hint == true:
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						target.set_owner(get_tree().edited_scene_root)
			
			target.name = "target"
		else:
			target = get_node("target")
		
		# If we are in the editor, we want to make a sphere at this node
		if Engine.editor_hint == true:
			_make_editor_sphere_at_node(target, Color(1, 0, 1, 1))
	
	if middle_joint_target == null:
		if has_node("middle_joint_target") == false:
			middle_joint_target = Spatial.new()
			add_child(middle_joint_target)
			
			if Engine.editor_hint == true:
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						middle_joint_target.set_owner(get_tree().edited_scene_root)
			
			middle_joint_target.name = "middle_joint_target"
		else:
			middle_joint_target = get_node("middle_joint_target")
	
		# If we are in the editor, we want to make a sphere at this node
		if Engine.editor_hint == true:
			_make_editor_sphere_at_node(middle_joint_target, Color(1, 0.24, 1, 1))
	
	# Make all of the bone nodes for each bone in the IK chain
	_make_bone_nodes()
	
	# Make sure we're using the right update mode
	_set_update_mode(update_mode)


func _make_editor_sphere_at_node(node, color):
	# So we can see the target in the editor, let's create a mesh instance,
	# Add it as our child, and name it
	var indicator = MeshInstance.new()
	node.add_child(indicator)
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
	indicator_material.albedo_color = color
	indicator_mesh.material = indicator_material
	indicator.mesh = indicator_mesh


############# SETGET FUNCTIONS #############


func _set_update_mode(new_value):
	update_mode = new_value
	
	set_process(false)
	set_physics_process(false)
	set_notify_transform(false)
	
	if update_mode == 0:
		set_process(true)
	elif update_mode == 1:
		set_process(true)
	elif update_mode == 2:
		set_notify_transform(true)
	else:
		if debug_messages == true:
			print (name, " - IK_FABRIK: Unknown update mode. NOT updating skeleton")
		return


func _set_skeleton_path(new_value):
	
	# Because get_node doesn't work in the first call, we just want to assign instead
	if first_call == true:
		skeleton_path = new_value
		return
	
	skeleton_path = new_value
	
	if skeleton_path == null:
		if debug_messages == true:
			print (name, " - IK_FABRIK: No Nodepath selected for skeleton_path!")
		return
	
	var temp = get_node(skeleton_path)
	if temp != null:
		# If it has the method "get_bone_global_pose" it is likely a Skeleton
		if temp.has_method("get_bone_global_pose") == true:
			skeleton = temp
			bone_IDs = {}
			
			# (Delete all of the old bone nodes and) Make all of the bone nodes for each bone in the IK chain
			_make_bone_nodes()
			
			if debug_messages == true:
				print (name, " - IK_FABRIK: Attached to a new skeleton")
		# If not, then it's (likely) not a Skeleton node
		else:
			skeleton = null
			if debug_messages == true:
				print (name, " - IK_FABRIK: skeleton_path does not point to a skeleton!")
	else:
		if debug_messages == true:
			print (name, " - IK_FABRIK: No Nodepath selected for skeleton_path!")

############# OTHER (NON IK SOLVER RELATED) FUNCTIONS #############


func _make_bone_nodes():
	# Remove all of the old bone nodes
	# TODO: (not a huge concern, as these can be removed in the editor)
	
	for bone in range(0, bones_in_chain.size()):
		
		var bone_name = bones_in_chain[bone]
		if has_node(bone_name) == false:
			var new_node = Spatial.new()
			bone_nodes[bone] = new_node
			add_child(bone_nodes[bone])
			
			if Engine.editor_hint == true:
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						bone_nodes[bone].set_owner(get_tree().edited_scene_root)
			
			bone_nodes[bone].name = bone_name
			
		else:
			bone_nodes[bone] = get_node(bone_name)
		
		# If we are in the editor, we want to make a sphere at this node
		if Engine.editor_hint == true:
			_make_editor_sphere_at_node(bone_nodes[bone], Color(0.65, 0, 1, 1))


func _set_bone_chain_bones(new_value):
	bones_in_chain = new_value
	
	_make_bone_nodes()

func _set_bone_chain_lengths(new_value):
	bones_in_chain_lengths = new_value
	total_length = null


# Various upate methods
# ---------------------
func _process(delta):
	if reset_iterations_on_update == true:
		chain_iterations = 0
	update_skeleton()
func _physics_process(delta):
	if reset_iterations_on_update == true:
		chain_iterations = 0
	update_skeleton()
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if reset_iterations_on_update == true:
			chain_iterations = 0
		update_skeleton()


############# IK SOLVER RELATED FUNCTIONS #############

func update_skeleton():
	
	#### ERROR CHECKING conditions
	if first_call == true:
		_set_skeleton_path(skeleton_path)
		first_call = false
		
		if skeleton == null:
			_set_skeleton_path(skeleton_path)
			
		return
	
	if bones_in_chain == null:
		if debug_messages == true:
			print (name, " - IK_FABRIK: No Bones in IK chain defined!")
		return
	if bones_in_chain_lengths == null:
		if debug_messages == true:
			print (name, " - IK_FABRIK: No Bone lengths in IK chain defined!")
		return
	
	if bones_in_chain.size() != bones_in_chain_lengths.size():
		if debug_messages == true:
			print (name, " - IK_FABRIK: bones_in_chain and bones_in_chain_lengths!")
		return
	
	################################
	
	# Set all of the bone IDs in bone_IDs, if they are not already made
	var i = 0
	if bone_IDs.size() <= 0:
		for bone_name in bones_in_chain:
			bone_IDs[bone_name] = skeleton.find_bone(bone_name)
			
			# Set the bone node to the currect bone position
			bone_nodes[i].global_transform = get_bone_transform(i)
			# If this is not the last bone in the bone chain, make it look at the next bone in the bone chain
			if i < bone_IDs.size()-1:
				bone_nodes[i].look_at(get_bone_transform(i+1).origin + skeleton.global_transform.origin, Vector3(0, 1, 0))
			
			i += 1
	
	# Set the total length of the bone chain, if it is not already set
	if total_length == null:
		total_length = 0
		for bone_length in bones_in_chain_lengths:
			total_length += bone_length
	
	
	# Solve the bone chain
	solve_chain()



func solve_chain():
	
	# If we have reached our max chain iteration, and we are limiting ourselves, then return.
	# Otherwise set chain_iterations to zero (so we constantly update)
	if chain_iterations >= CHAIN_MAX_ITER and limit_chain_iterations == true:
		return
	else:
		chain_iterations = 0
	
	# Update the origin with the current bone's origin
	chain_origin = get_bone_transform(0)
	
	# Get the direction of the final bone by using the next to last bone if there is more than 2 bones.
	# If there are only 2 bones, we use the target's forward Z vector instead (not ideal, but it works fairly well)
	#var dir = -target.global_transform.basis.z.normalized()
	var dir
	if bone_nodes.size() > 2:
		dir = bone_nodes[bone_nodes.size()-2].global_transform.basis.z.normalized()
	else:
		dir = -target.global_transform.basis.z.normalized()
	
	# Get the target position (accounting for the final bone and it's length)
	var target_pos = target.global_transform.origin + (dir * bones_in_chain_lengths[bone_nodes.size()-1])
	
	# If we are using middle joint target (and have more than 2 bones), move our middle joint towards it!
	if use_middle_joint_target == true:
		if bone_nodes.size() > 2:
			var middle_point_pos = middle_joint_target.global_transform
			bone_nodes[bone_nodes.size()/2].global_transform.origin = middle_point_pos.origin
	
	# Get the distance from the origin to the target
	var distance = (chain_origin.origin - target_pos).length()
	
	# If the distance is farther than our total reach, the target cannot be reached.
	# Make the bone chain a straight line pointing towards the target
	if distance > total_length:
		for i in range (0, bones_in_chain.size()):
			# Create a direct line to target and make this bone travel down that line
			
			var r = (target_pos - bone_nodes[i].global_transform.origin).length()
			var l = bones_in_chain_lengths[i] / r
			
			# Find new join position
			var new_pos = (1-l) * bone_nodes[i].global_transform.origin + l * target_pos
			
			# Apply it to the bone node
			bone_nodes[i].look_at(new_pos, Vector3(0, 1, 0))
			bone_nodes[i].global_transform.origin = new_pos
		
		# Apply the rotation to the first node in the bone chain, making it look at the next bone in the bone chain
		bone_nodes[0].look_at(bone_nodes[1].global_transform.origin, Vector3(0, 1, 0))
	
	# If the distance is NOT farther than our total reach, the target can be reached.
	else:
		# Get the difference between our end effector (the final bone in the chain) and the target
		var dif = (bone_nodes[bone_nodes.size()-1].global_transform.origin - target_pos).length()
		
		# Check to see if the distance from the end effector to the target is within our error margin (CHAIN_TOLERANCE).
		# If it not, move the chain towards the target (going forwards, backwards, and then applying rotation)
		while dif > CHAIN_TOLERANCE:
			chain_backward()
			chain_forward()
			chain_apply_rotation()
			
			# Update the difference between our end effector (the final bone in the chain) and the target
			dif = (bone_nodes[bone_nodes.size()-1].global_transform.origin - target_pos).length()
			
			# Add one to chain_iterations. If we have reached our max iterations, then break
			chain_iterations = chain_iterations + 1
			if chain_iterations >= CHAIN_MAX_ITER:
				break
	
	# Reset the bone node transforms to the skeleton bone transforms
	#if (constrained == false): # Resetting seems to break bone constraints...
	for i in range(0, bone_nodes.size()):
		var reset_bone_trans = get_bone_transform(i)
		bone_nodes[i].global_transform = reset_bone_trans


func chain_backward():
	# Backward reaching pass
	
	# Get the direction of the final bone by using the next to last bone if there is more than 2 bones.
	# If there are only 2 bones, we use the target's forward Z vector instead (not ideal, but it works fairly well)
	var dir
	if bone_nodes.size() > 2:
		dir = bone_nodes[bone_nodes.size()-2].global_transform.basis.z.normalized()
	else:
		dir = -target.global_transform.basis.z.normalized()
	
	# Set the position of the end effector (the final bone in the chain) to the target position
	bone_nodes[bone_nodes.size()-1].global_transform.origin = target.global_transform.origin + (dir * bones_in_chain_lengths[bone_nodes.size()-1])
	
	# For all of the other bones, move them towards the target
	var i = bones_in_chain.size() - 1
	while i >= 1:
		
		i -= 1
		
		var r = bone_nodes[i+1].global_transform.origin - bone_nodes[i].global_transform.origin
		var l = bones_in_chain_lengths[i] / r.length()
		# Apply the new joint position
		bone_nodes[i].global_transform.origin = (1 - l) * bone_nodes[i+1].global_transform.origin + l * bone_nodes[i].global_transform.origin


func chain_forward():
	# Forward reaching pass
	
	# Set root at initial position
	bone_nodes[0].global_transform.origin = chain_origin.origin
	
	# Go through every bone in the bone chain
	var i = 0
	while i < bones_in_chain.size() - 1:
		
		var r = (bone_nodes[i+1].global_transform.origin - bone_nodes[i].global_transform.origin)
		var l = bones_in_chain_lengths[i] / r.length()
		
		# Set the new joint position
		var new_pos = (1 - l) * bone_nodes[i].global_transform.origin + l * bone_nodes[i+1].global_transform.origin
		
		# Apply the new joint position, (potentially with constraints), to the bone node
		bone_nodes[i+1].global_transform.origin = new_pos
		
		i += 1


func chain_apply_rotation():
	# Make all of the bones rotated correctly.
	
	# For each bone in the bone chain
	for i in range(0, bones_in_chain.size()):
		
		# Get the bone's transform, NOT converted to world space
		var bone_trans = get_bone_transform(i, false)
		
		# If this is the last bone in the bone chain, rotate the bone so it faces
		# the same direction as the next to last bone in the bone chain if there are more than
		# two bones. If there are only two bones, rotate the end effector towards the target
		if i == bones_in_chain.size()-1:
			
			if bones_in_chain.size() > 2:
				# Get the bone node for this bone, and the previous bone
				var b_target = bone_nodes[i].global_transform
				var b_target_two = bone_nodes[i-1].global_transform
				
				# Convert the bone nodes positions from world space to bone/skeleton space
				b_target.origin = skeleton.global_transform.xform_inv(b_target.origin)
				b_target_two.origin = skeleton.global_transform.xform_inv(b_target_two.origin)
				
				# Get the direction that the previous bone is pointing towards
				var dir = (target.global_transform.origin - b_target_two.origin).normalized()
				
				# Make this bone look in the same the direction as the last bone
				bone_trans = bone_trans.looking_at(b_target.origin + dir, Vector3(0, 1, 0))
			else:
				var b_target = target.global_transform
				b_target.origin = skeleton.global_transform.xform_inv(b_target.origin)
				bone_trans = bone_trans.looking_at(b_target.origin, Vector3(0, 1, 0))
		
		# If this is NOT the last bone in the bone chain, rotate the bone to look at the next
		# bone in the bone chain.
		else:
			# Get the bone node for this bone, and the next bone
			var b_target = bone_nodes[i].global_transform
			var b_target_two = bone_nodes[i+1].global_transform
			
			# Convert the bone nodes positions from world space to bone/skeleton space
			b_target.origin = skeleton.global_transform.xform_inv(b_target.origin)
			b_target_two.origin = skeleton.global_transform.xform_inv(b_target_two.origin)
			
			# Get the direction towards the next bone
			var dir = (b_target_two.origin - b_target.origin).normalized()
			
			# Make this bone look towards the direction of the next bone
			bone_trans = bone_trans.looking_at(b_target.origin + dir, Vector3(0, 1, 0))
		
		# The the bone's (updated) transform
		set_bone_transform(i, bone_trans)


func get_bone_transform(bone, convert_to_world_space=true):
	
	# Get the global transform of the bone
	var ret = skeleton.get_bone_global_pose(bone_IDs[bones_in_chain[bone]])
	
	# If we need to convert the bone position from bone/skeleton space to world space, we
	# use the Xform of the skeleton (because bone/skeleton space is relative to the position of the skeleton node).
	if convert_to_world_space == true:
		ret.origin = skeleton.global_transform.xform(ret.origin)
	
	return ret


func set_bone_transform(bone, trans):
	# Set the global transform of the bone
	skeleton.set_bone_global_pose(bone_IDs[bones_in_chain[bone]], trans)


