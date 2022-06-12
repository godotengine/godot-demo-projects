extends Button

enum SpeedUnit {
	METERS_PER_SECOND = 0,
	KILOMETERS_PER_HOUR = 1,
	MILES_PER_HOUR = 2,
}

export(SpeedUnit) var speed_unit = 0

func _process(_delta):
	var speed = get_parent().get_parent().get_child(1).get_child(0).linear_velocity.length()
	if speed_unit == SpeedUnit.METERS_PER_SECOND:
		text = "Speed: " + ("%.1f" % speed) + " m/s"
	elif speed_unit == SpeedUnit.KILOMETERS_PER_HOUR:
		speed *= 3.6
		text = "Speed: " + ("%.0f" % speed) + " km/h"
	else: # speed_unit == SpeedUnit.MILES_PER_HOUR:
		speed *= 2.23694
		text = "Speed: " + ("%.0f" % speed) + " mph"


func _on_Spedometer_pressed():
	speed_unit = (speed_unit + 1) % 3
