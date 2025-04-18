extends HBoxContainer


func _on_h_slider_value_changed(value: float) -> void:
	$Value.text = str(roundi(value))
	Engine.max_physics_steps_per_frame = roundi(value)
