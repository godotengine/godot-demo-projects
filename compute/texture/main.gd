extends Node3D

# Note, the code here just adds some control to our effects.
# Check res://water_plane/water_plane.gd for the real implementation.

var y = 0.0

@onready var water_plane = $WaterPlane

func _ready():
	$Container/RainSize/HSlider.value = $WaterPlane.rain_size
	$Container/MouseSize/HSlider.value = $WaterPlane.mouse_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Container/Rotate.button_pressed:
		y += delta
		water_plane.basis = Basis(Vector3.UP, y)


func _on_rain_size_changed(value):
	$WaterPlane.rain_size = value


func _on_mouse_size_changed(value):
	$WaterPlane.mouse_size = value
