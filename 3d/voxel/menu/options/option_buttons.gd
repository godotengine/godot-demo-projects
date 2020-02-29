extends Control

onready var render_distance_label = $RenderDistanceLabel
onready var render_distance_slider = $RenderDistanceSlider
onready var fog_checkbox = $FogCheckBox


func _ready():
	render_distance_slider.value = Settings.render_distance
	render_distance_label.text = "Render distance: " + str(Settings.render_distance)
	fog_checkbox.pressed = Settings.fog_enabled


func _on_RenderDistanceSlider_value_changed(value):
	Settings.render_distance = value
	render_distance_label.text = "Render distance: " + str(value)
	Settings.save_settings()


func _on_FogCheckBox_pressed():
	Settings.fog_enabled = fog_checkbox.pressed
	Settings.save_settings()
