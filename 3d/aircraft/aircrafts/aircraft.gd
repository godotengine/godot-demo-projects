extends VehicleBody3D
class_name Aircraft

@export var flap_modes: Array[float] = [0.0, 1.0 / 3.0, 2.0 / 3.0, 1.0]
@export var brake_value := 1.0
@export var horizontal_height := 0.0
@export var horizontal_rotation := 0.0
@export var camera_distance := 8.0

@onready var wing := $Wing as VehicleWing3D
@onready var elevator := $Elevator as VehicleWing3D
@onready var rudder := $Rudder as VehicleWing3D
@onready var motor := $Motor as Motor

var flap_mode := 0
