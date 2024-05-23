extends RigidBody3D

var _dir := 1.0
var _distance := 10.0
var _walk_spd := 100.0
var _acceleration := 22.0
var _is_on_floor := false

@onready var _forward := -transform.basis.z
@onready var _collision_shape := $CollisionShape
@onready var _material: StandardMaterial3D = $CollisionShape/MeshInstance3D.get_active_material(0)

func _ready() -> void:
	if not _material:
		_material = StandardMaterial3D.new()
		$CollisionShape/MeshInstance3D.set_surface_override_material(0, _material)


func _process(_delta: float) -> void:
	if _is_on_floor:
		_material.albedo_color = Color.WHITE
	else:
		_material.albedo_color = Color.RED


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var delta := state.step
	var velocity := (_forward * _dir * _walk_spd * delta) + (state.linear_velocity  * Vector3.UP)
	state.linear_velocity = state.linear_velocity.move_toward(velocity, _acceleration * delta)

	if state.transform.origin.z < -_distance:
		_dir = -1
	if state.transform.origin.z > _distance:
		_dir = 1

	ground_check()


func ground_check() -> void:
	var space_state := get_world_3d().direct_space_state
	var shape := PhysicsShapeQueryParameters3D.new()
	shape.transform = _collision_shape.global_transform
	shape.shape_rid = _collision_shape.shape.get_rid()
	shape.collision_mask = 2
	var result := space_state.get_rest_info(shape)
	if result:
		_is_on_floor = true
	else:
		_is_on_floor = false
