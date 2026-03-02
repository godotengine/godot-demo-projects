extends Button

enum SpeedUnit {
	METERS_PER_SECOND,
	KILOMETERS_PER_HOUR,
	MILES_PER_HOUR,
}

var car_body: VehicleBody3D

@export var tint_gradient: Gradient
@export var speed_unit: SpeedUnit = SpeedUnit.METERS_PER_SECOND

func _process(_delta: float) -> void:
	var speed := car_body.linear_velocity.length()
	if speed_unit == SpeedUnit.METERS_PER_SECOND:
		text = "Speed: " + ("%.1f" % speed) + " m/s"
	elif speed_unit == SpeedUnit.KILOMETERS_PER_HOUR:
		speed *= 3.6
		text = "Speed: " + ("%.0f" % speed) + " km/h"
	else: # speed_unit == SpeedUnit.MILES_PER_HOUR:
		speed *= 2.23694
		text = "Speed: " + ("%.0f" % speed) + " mph"

	# Change speedometer color depending on speed in m/s (regardless of unit).
	add_theme_color_override(&"font_color", tint_gradient.sample(remap(car_body.linear_velocity.length(), 0.0, 30.0, 0.0, 1.0)))


func _on_speedometer_pressed() -> void:
	speed_unit = ((speed_unit + 1) % SpeedUnit.size()) as SpeedUnit
