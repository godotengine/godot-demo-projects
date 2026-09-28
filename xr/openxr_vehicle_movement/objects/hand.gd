extends XRController3D
class_name XRHand3D

# TODO: Add nice meshes for hands, use tracker to know which one


func get_hand_mesh_path() -> NodePath:
	return $Mesh.get_path()


func set_hand_mesh_toplevel(p_top_level : bool):
	$Mesh.top_level = p_top_level
	if !p_top_level:
		# Reset transform
		$Mesh.transform = Transform3D()
		$GhostMesh.visible = false
	else:
		# Show our real hand position
		$GhostMesh.visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pose = "hand_pose" # this sometimes gets lost
	visible = false
	%Collision.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float):
	visible = get_has_tracking_data()
	%Collision.disabled = !visible
