# Adds a simple shadow below an object.
# Place this ShadowMath25D node as a child of a Shadow25D, which
# is below the target object in the scene tree (not as a child).
@tool
@icon("res://addons/node25d/icons/shadow_math_25d_icon.png")
class_name ShadowMath25D
extends ShapeCast3D

var _shadow_root: Node25D
var _target_math: Node3D


func _ready() -> void:
	_shadow_root = get_parent()

	var index := _shadow_root.get_index()
	if index > 0:  # Else, shadow is not in a valid place.
		var sibling_25d: Node = _shadow_root.get_parent().get_child(index - 1)
		if sibling_25d.get_child_count() > 0:
			var target = sibling_25d.get_child(0)
			if target is Node3D:
				_target_math = target
				return

	push_error("Shadow is not in the correct place, expected a previous sibling node with a 3D first child.")


func _physics_process(_delta: float) -> void:
	if _target_math == null:
		if _shadow_root != null:
			_shadow_root.visible = false
		return  # Shadow is not in a valid place or you're viewing the Shadow25D scene.

	position = _target_math.position
	force_shapecast_update()

	if is_colliding():
		global_position = get_collision_point(0)
		_shadow_root.visible = true
	else:
		_shadow_root.visible = false
