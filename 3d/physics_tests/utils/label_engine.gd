extends Label


func _process(_delta):
	var engine_name = ""
	match System.get_physics_engine():
		System.PhysicsEngine.GODOT_PHYSICS:
			engine_name = "GodotPhysics 3D"
		System.PhysicsEngine.OTHER:
			var engine_setting = ProjectSettings.get_setting("physics/3d/physics_engine")
			engine_name = "Other (%s)" % engine_setting
	set_text("Physics engine: %s" % engine_name)
