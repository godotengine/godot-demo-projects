extends RigidBody

onready var _forward:Vector3 = -transform.basis.z
onready var _collision_shape:CollisionShape = $CollisionShape
onready var _material:SpatialMaterial = $CollisionShape/MeshInstance.get_surface_material(0)

var _dir:float = 1.0
var _distance:float = 10.0
var _walk_spd:float = 100.0
var _acceleration:float = 22.0
var _gravity_impulse:float = 30.0
var _is_on_floor:bool = false

func _integrate_forces(state:PhysicsDirectBodyState):
	var delta = state.step
	var velocity:Vector3 = (_forward *_dir *_walk_spd *delta) +(state.linear_velocity  *Vector3(0,1,0))
	state.linear_velocity = state.linear_velocity.move_toward(velocity, _acceleration * delta)
	
	if state.transform.origin.z < -_distance:
		_dir = -1
	if state.transform.origin.z > _distance:
		_dir = 1
	
	ground_check()

func ground_check()->void:
	var space_state: = get_world().direct_space_state
	var shape: = PhysicsShapeQueryParameters.new()
	shape.transform = _collision_shape.global_transform
	shape.shape_rid = _collision_shape.shape.get_rid()
	shape.collision_mask = 2
	var result: = space_state.get_rest_info(shape)
	if result:
		_is_on_floor = true
	else:
		_is_on_floor = false

func _process(_delta:float)->void:
	if _is_on_floor:
		_material.albedo_color = Color.white
	else:
		_material.albedo_color = Color.red
