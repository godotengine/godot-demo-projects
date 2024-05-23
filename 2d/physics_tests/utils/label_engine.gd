extends Label

func _ready() -> void:
	var engine_name := ""

	match System.get_physics_engine():
		System.PhysicsEngine.GODOT_PHYSICS:
			engine_name = "GodotPhysics 2D"
		System.PhysicsEngine.OTHER:
			var engine_setting := String(ProjectSettings.get_setting("physics/2d/physics_engine"))
			engine_name = "Other (%s)" % engine_setting

	text = "Physics engine: %s" % engine_name
