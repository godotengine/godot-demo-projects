extends Label

func _ready() -> void:
	var engine_name := ""
	match System.get_physics_engine():
		System.PhysicsEngine.GODOT_PHYSICS:
			engine_name = "GodotPhysics 3D"
		System.PhysicsEngine.OTHER:
			var engine_setting := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
			engine_name = "Other (%s)" % engine_setting

	text = "Physics engine: %s" % engine_name
