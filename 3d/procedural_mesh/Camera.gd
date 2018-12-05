# Based on godot-flying-camera-3d
# Copyright (c) 2017 Maksym Nimenko
# https://github.com/nimenko/godot-flying-camera-3d

extends Camera

export(float) var mouse_sensitivity : float = 0.0001
export(float) var camera_speed : float = 0.1

const X_AXIS = Vector3(1, 0, 0)
const Y_AXIS = Vector3(0, 1, 0)

var is_mouse_motion := false

var mouse_speed := Vector2()
var mouse_speed_x : float = 0
var mouse_speed_y : float = 0

onready var camera_transform := self.get_transform()

func _ready() -> void:
	pass


func _physics_process(delta : float) -> void:
	if (is_mouse_motion):
		mouse_speed = Input.get_last_mouse_speed()
		is_mouse_motion = false
	else:
		mouse_speed = Vector2(0, 0)
	
	mouse_speed_x += mouse_speed.x * mouse_sensitivity
	mouse_speed_y += mouse_speed.y * mouse_sensitivity
	
	var rot_x := Quat(X_AXIS, -mouse_speed_y)
	var rot_y := Quat(Y_AXIS, -mouse_speed_x)
	
	if (Input.is_key_pressed(KEY_W)):
		camera_transform.origin += -self.get_transform().basis.z * camera_speed
	
	if (Input.is_key_pressed(KEY_S)):
		camera_transform.origin += self.get_transform().basis.z * camera_speed
	
	if (Input.is_key_pressed(KEY_A)):
		camera_transform.origin += -self.get_transform().basis.x * camera_speed
	
	if (Input.is_key_pressed(KEY_D)):
		camera_transform.origin += self.get_transform().basis.x * camera_speed
	
	if (Input.is_key_pressed(KEY_Q)):
		camera_transform.origin += -self.get_transform().basis.y * camera_speed
	
	if (Input.is_key_pressed(KEY_SPACE)):
		camera_transform.origin += self.get_transform().basis.y * camera_speed
	
	if (Input.is_key_pressed(KEY_SHIFT)):
		camera_transform.origin += -self.get_transform().basis.y * camera_speed
	
	
	if (Input.is_key_pressed(KEY_E)):
		camera_transform.origin += self.get_transform().basis.y * camera_speed
	
	self.set_transform(camera_transform * Transform(rot_y) * Transform(rot_x))


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		is_mouse_motion = true

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			camera_speed = max(0.1, camera_speed + 0.05)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera_speed = max(0.1, camera_speed - 0.05)
