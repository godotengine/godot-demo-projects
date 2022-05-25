#@tool
class_name SkeletonModification3DGDScript
extends SkeletonModification3D


@export_node_path(Node3D) var rotation_target_path;
@export var use_local_basis:bool = false;
var rotation_target:Node3D;
@export var bone_idx:int;

func setup_modification(_stack):
	#print ("Setup called from GDScript!");
	return;

func execute(_delta):
	var stack : SkeletonModificationStack3D = get_modification_stack();
	var skeleton : Skeleton3D = stack.get_skeleton();

	if not enabled:
		return;

	if bone_idx > 0 and bone_idx < skeleton.get_bone_count():
		var local_override_trans = skeleton.get_bone_local_pose_override(bone_idx);

		rotation_target = skeleton.get_node(rotation_target_path) as Node3D;
		var target_working_trans = rotation_target.global_transform;

		if (use_local_basis):
			target_working_trans.basis = rotation_target.transform.basis;

		target_working_trans = skeleton.world_transform_to_global_pose(target_working_trans);
		target_working_trans = skeleton.global_pose_to_local_pose(bone_idx, target_working_trans);
		target_working_trans.basis = target_working_trans.basis.orthonormalized().scaled(local_override_trans.basis.get_scale());
		local_override_trans.basis = target_working_trans.basis;

		skeleton.set_bone_local_pose_override(bone_idx, local_override_trans, stack.strength, self.enabled);
		skeleton.force_update_bone_child_transform(bone_idx);

	#print ("Executed custom modification!");
