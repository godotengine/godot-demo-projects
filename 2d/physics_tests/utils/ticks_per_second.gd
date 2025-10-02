extends HBoxContainer


func _on_h_slider_value_changed(value: float) -> void:
	$Value.text = str(roundi(value))
	Engine.physics_ticks_per_second = roundi(value * Engine.time_scale)
