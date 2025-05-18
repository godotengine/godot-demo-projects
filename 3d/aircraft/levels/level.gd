extends Node3D

@export var aircrafts: Array[PackedScene]

@onready var info_panel := $InfoPanel as InfoPanel
@onready var aircraft_name := $AircraftName as Label

var aircraft: Aircraft
var aircraft_index := 0


func _ready() -> void:
	spawn_aircraft(aircraft_index)


func spawn_aircraft(index: int) -> void:
	clear()
	aircraft_index = index
	if index < 0 or index >= len(aircrafts) or aircrafts[index] == null:
		return
	aircraft = aircrafts[index].instantiate() as Aircraft
	if aircraft == null:
		return
	aircraft.position.y = aircraft.horizontal_height
	aircraft.rotation.x = deg_to_rad(aircraft.horizontal_rotation)
	var camera := AircraftCamera.new()
	camera.distance = aircraft.camera_distance
	aircraft.add_child(camera, true)
	aircraft.add_child(PlayerAircraftController.new())
	add_child(aircraft, true)
	if info_panel != null:
		info_panel.aircraft = aircraft
	if aircraft_name != null:
		aircraft_name.text = aircraft.name


func clear() -> void:
	if aircraft != null:
		aircraft.queue_free()
		aircraft = null
	if info_panel != null:
		info_panel.aircraft = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_next"):
		spawn_next()


func spawn_next() -> void:
	if len(aircrafts) > 0:
		spawn_aircraft((aircraft_index + 1) % len(aircrafts))
