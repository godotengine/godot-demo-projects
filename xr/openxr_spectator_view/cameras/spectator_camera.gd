extends Camera3D

## If true, we are in control of positioning.
@export var enable_positioning: bool = true:
	set(value):
		if enable_positioning == value:
			return

		enable_positioning = value
		if is_inside_tree():
			$Area3D/CollisionShape3D.disabled = not enable_positioning
			if enable_positioning:
				# We just turned this on? Reset this
				global_transform = last_transform

## Our camera should be pointed at this node.
@export var lookat_node: Node3D

@onready var last_transform: Transform3D = global_transform
@onready var display: MeshInstance3D = $CameraBody/DisplayContainer/Display


# Called when the node enters the scene tree for the first time.
func _ready():
	var material: ShaderMaterial = display.material_override
	if material:
		material.set_shader_parameter(&"albedo_texture", get_viewport().get_texture())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not enable_positioning:
		return

	# Make sure we look in the right direction.
	if lookat_node:
		look_at(lookat_node.global_position, Vector3.UP, false)

	# Remember this.
	last_transform = global_transform
