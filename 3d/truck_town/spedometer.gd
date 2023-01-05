extends Button

enum SpeedUnit {
	METERS_PER_SECOND,
	KILOMETERS_PER_HOUR,
	MILES_PER_HOUR,
}

@export var speed_unit: SpeedUnit = SpeedUnit.METERS_PER_SECOND

var gradient := Gradient.new()
var car_body: VehicleBody3D


func _ready():
	# The start and end points (offset 0.0 and 1.0) are already defined in a Gradient
	# resource on creation. Override their colors and only create one new point.
	gradient.set_color(0, Color(0.7, 0.9, 1.0))
	gradient.set_color(1, Color(1.0, 0.3, 0.1))
	gradient.add_point(0.2, Color(1.0, 1.0, 1.0))


func _process(_delta):
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
	add_theme_color_override("font_color", gradient.sample(remap(car_body.linear_velocity.length(), 0.0, 30.0, 0.0, 1.0)))


func _on_spedometer_pressed():
	speed_unit = ((speed_unit + 1) % SpeedUnit.size()) as SpeedUnit
