extends Button

enum SpeedUnit {
	METERS_PER_SECOND,
	KILOMETERS_PER_HOUR,
	MILES_PER_HOUR,
}

@export var speed_unit: SpeedUnit = SpeedUnit.METERS_PER_SECOND

var car_body: VehicleBody3D

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


func _on_spedometer_pressed():
	speed_unit = ((speed_unit + 1) % SpeedUnit.size()) as SpeedUnit
