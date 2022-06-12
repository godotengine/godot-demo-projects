extends RigidBody


onready var _forward = - transform.basis.z
onready var _collision_shape = $CollisionShape
onready var _material = $CollisionShape/MeshInstance.get_surface_material(0)

var _dir = 1.0
var _distance = 10.0
var _walk_spd = 100.0
var _acceleration = 22.0
var _gravity_impulse = 30.0
var _is_on_floor = false


func _process(_delta):
	if _is_on_floor:
		_material.albedo_color = Color.white
	else:
		_material.albedo_color = Color.red


func _integrate_forces(state):
	var delta = state.step
	var velocity = (_forward * _dir * _walk_spd * delta) + (state.linear_velocity  * Vector3.UP)
	state.linear_velocity = state.linear_velocity.move_toward(velocity, _acceleration * delta)

	if state.transform.origin.z < -_distance:
		_dir = -1
	if state.transform.origin.z > _distance:
		_dir = 1

	ground_check()


func ground_check():
	var space_state = get_world().direct_space_state
	var shape = PhysicsShapeQueryParameters.new()
	shape.transform = _collision_shape.global_transform
	shape.shape_rid = _collision_shape.shape.get_rid()
	shape.collision_mask = 2
	var result = space_state.get_rest_info(shape)
	if result:
		_is_on_floor = true
	else:
		_is_on_floor = false
