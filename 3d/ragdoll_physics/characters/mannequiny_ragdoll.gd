extends Node3D

const IMPACT_SOUND_SPEED_SMALL = 0.3
const IMPACT_SOUND_SPEED_BIG = 1.0

## The velocity to apply on the first physics frame.
@export var initial_velocity: Vector3

var has_applied_initial_velocity: bool = false
# Used to play an impact sound on sudden velocity changes.
# We use the pelvis bone as it's close to the center of mass of the character model.
# For more detailed impact sounds, you could place multiple AudioStreamPlayer nodes as a child
# of each limb.
var previous_pelvis_speed: float = 0.0

@onready var pelvis: PhysicalBone3D = $"root/root_001/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone pelvis"


func _ready() -> void:
	$root/root_001/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	if not initial_velocity.is_zero_approx():
		for physical_bone in $root/root_001/Skeleton3D/PhysicalBoneSimulator3D.get_children():
			# Give the ragdoll an initial motion by applying velocity on all its bones upon being spawned.
			physical_bone.apply_central_impulse(initial_velocity)


func _physics_process(_delta: float) -> void:
	var pelvis_speed: float = pelvis.linear_velocity.length()
	# Ensure the speed used to determine the threshold doesn't change with time scale.
	var impact_speed := (previous_pelvis_speed - pelvis_speed) / Engine.time_scale
	if impact_speed > IMPACT_SOUND_SPEED_BIG:
		$ImpactSoundBig.play()
	elif impact_speed > IMPACT_SOUND_SPEED_SMALL:
		$ImpactSoundSmall.play()

	previous_pelvis_speed = pelvis_speed
