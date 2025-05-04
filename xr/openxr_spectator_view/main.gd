extends "res://start_vr.gd"

@export var tracked_camera : Node3D:
	set(value):
		tracked_camera = value
		if tracked_camera:
			%CameraRemoteTransform3D.remote_path = tracked_camera.get_path()
		else:
			%CameraRemoteTransform3D.remote_path = NodePath()
