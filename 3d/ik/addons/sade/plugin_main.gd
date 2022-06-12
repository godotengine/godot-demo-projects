tool
extends EditorPlugin

func _enter_tree():
	# Plugin Initialization here!
	add_custom_type("IK_LookAt", "Spatial", preload("ik_look_at.gd"), preload("ik_look_at.png"))
	add_custom_type("IK_FABRIK", "Spatial", preload("ik_fabrik.gd"), preload("ik_fabrik.png"))


func _exit_tree():
	# Plugin Clean-up here!
	remove_custom_type("IK_LookAt")
	remove_custom_type("IK_FABRIK")
