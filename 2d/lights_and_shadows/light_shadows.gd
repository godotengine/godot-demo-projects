extends Node2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_directional_light"):
		$DirectionalLight2D.visible = not $DirectionalLight2D.visible

	if event.is_action_pressed("toggle_point_lights"):
		for point_light in get_tree().get_nodes_in_group("point_light"):
			point_light.visible = not point_light.visible

	if event.is_action_pressed("cycle_directional_light_shadows_quality"):
		$DirectionalLight2D.shadow_filter = wrapi($DirectionalLight2D.shadow_filter + 1, 0, 3)

	if event.is_action_pressed("cycle_point_light_shadows_quality"):
		for point_light in get_tree().get_nodes_in_group("point_light"):
			point_light.shadow_filter = wrapi(point_light.shadow_filter + 1, 0, 3)
