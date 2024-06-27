@tool
extends Area3D
class_name PickupHandler3D

# This area3D class detects all physics bodys based on
# PickupAbleBody3D within range and handles the logic
# for selecting the closest one and allowing pickup
# of that object.

# Detect range specifies within what radius we detect
# objects we can pick up.
@export var detect_range : float = 0.3:
	set(value):
		detect_range = value
		if is_inside_tree():
			_update_detect_range()
			_update_closest_body()

# Pickup Action specifies the action in the OpenXR
# action map that triggers our pickup function.
@export var pickup_action : String = "pickup"

var closest_body : PickupAbleBody3D
var picked_up_body: PickupAbleBody3D
var was_pickup_pressed : bool = false

# Update our detection range.
func _update_detect_range() -> void:
	var shape : SphereShape3D = $CollisionShape3D.shape
	if shape:
		shape.radius = detect_range


# Update our closest body.
func _update_closest_body() -> void:
	# Do not do this when we're in the editor.
	if Engine.is_editor_hint():
		return

	# Do not check this if we've picked something up.
	if picked_up_body:
		if closest_body:
			closest_body.remove_is_closest(self)
			closest_body = null

		return

	# Find the body that is currently the closest.
	var new_closest_body : PickupAbleBody3D
	var closest_distance : float = 1000000.0

	for body in get_overlapping_bodies():
		if body is PickupAbleBody3D and not body.is_picked_up():
			var distance_squared = (body.global_position - global_position).length_squared()
			if distance_squared < closest_distance:
				new_closest_body = body
				closest_distance = distance_squared

	# Unchanged? Just exit
	if closest_body == new_closest_body:
		return

	# We had a closest body
	if closest_body:
		closest_body.remove_is_closest(self)

	closest_body = new_closest_body
	if closest_body:
		closest_body.add_is_closest(self)


# Get our controller that we are a child of
func _get_parent_controller() -> XRController3D:
	var parent : Node = get_parent()
	while parent:
		if parent is XRController3D:
			return parent

		parent = parent.get_parent()

	return null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_detect_range()
	_update_closest_body()


# Called every physics frame
func _physics_process(delta) -> void:
	# As we move our hands we need to check if the closest body
	# has changed.
	_update_closest_body()

	# Check if our pickup action is true
	var pickup_pressed = false
	var controller : XRController3D = _get_parent_controller()
	if controller:
		# While OpenXR can return this as a boolean, there is a lot of
		# difference in handling thresholds between platforms.
		# So we implement our own logic here.
		var pickup_value : float = controller.get_float(pickup_action)
		var threshold : float = 0.4 if was_pickup_pressed else 0.6
		pickup_pressed = pickup_value > threshold

	# Do we need to let go?
	if picked_up_body and not pickup_pressed:
		picked_up_body.let_go()
		picked_up_body = null

	# Do we need to pick something up
	if not picked_up_body and not was_pickup_pressed and pickup_pressed and closest_body:
		picked_up_body = closest_body
		picked_up_body.pick_up(self)

	# Remember our state for the next frame
	was_pickup_pressed = pickup_pressed
