extends Node3D

const MOUSE_SENSITIVITY = 0.01
const INITIAL_VELOCITY_STRENGTH = 0.5

# Margin to add to the automatically computed shadow maximum distance.
# This value was empirically chosen to cover the whole scene when zoomed
# all the way in.
const DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN = 9.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var directional_light: DirectionalLight3D = $DirectionalLight3D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reset_simulation"):
		get_tree().reload_current_scene()

	if event.is_action_pressed(&"place_ragdoll"):
		var origin := camera.global_position
		var target := camera.project_position(get_viewport().get_mouse_position(), 100)

		var query := PhysicsRayQueryParameters3D.create(origin, target)
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			var ragdoll := preload("res://characters/mannequiny_ragdoll.tscn").instantiate()
			ragdoll.position = result["position"] + Vector3(0.0, 0.5, 0.0)
			# Make newly spawned ragdolls face the camera.
			ragdoll.rotation.y = camera_pivot.rotation.y
			# Give some initial velocity in a random horizontal direction.
			ragdoll.initial_velocity = Vector3.FORWARD.rotated(Vector3.UP, randf_range(0, TAU)) * INITIAL_VELOCITY_STRENGTH
			add_child(ragdoll)

	if event.is_action_pressed(&"slow_motion"):
		Engine.time_scale = 0.25
		# Don't set pitch scale too low as it sounds strange.
		# `0.5` is the square root of `0.25` and gives a good result here.
		AudioServer.playback_speed_scale = 0.5

	if event.is_action_released(&"slow_motion"):
		Engine.time_scale = 1.0
		AudioServer.playback_speed_scale = 1.0

	# Pan the camera with right mouse button.
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		if mouse_motion.button_mask & MOUSE_BUTTON_RIGHT:
			camera_pivot.global_rotation.x = clampf(camera_pivot.global_rotation.x - event.screen_relative.y * MOUSE_SENSITIVITY, -TAU * 0.249, TAU * 0.021)
			camera_pivot.global_rotation.y -= event.screen_relative.x * MOUSE_SENSITIVITY

	# Zoom with mouse wheel.
	# This also adjusts shadow maximum distance to always cover the scene regardless of zoom level.
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.translate_object_local(Vector3.FORWARD * 0.5)
			directional_light.directional_shadow_max_distance = camera.position.length() + DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate_object_local(Vector3.BACK * 0.5)
			directional_light.directional_shadow_max_distance = camera.position.length() + DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN
