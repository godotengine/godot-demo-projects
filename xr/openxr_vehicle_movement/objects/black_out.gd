@tool
extends Node3D

const LABEL_FORWARD_DIST : float = 2.5

@export_range(0, 1, 0.1) var fade = 0.0:
	set(value):
		fade = value
		if is_inside_tree():
			_update_fade()

var material : ShaderMaterial

func _update_fade():
	if fade == 0.0:
		$MeshInstance3D.visible = false
		$Label3D.visible = false
		set_process(false)
	else:
		# Update fade
		if material:
			material.set_shader_parameter("albedo", Color(0.0, 0.0, 0.0, fade))
		$MeshInstance3D.visible = true

		# Update label
		$Label3D.modulate = Color(1.0, 1.0, 1.0, fade)
		$Label3D.outline_modulate = Color(0.0, 0.0, 0.0, fade)
		$Label3D.visible = true
		set_process(true)


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label3D.top_level = true
	material = $MeshInstance3D.material_override
	_update_fade()


# Called every frame
func _process(_delta):
	if $Label3D.visible and !Engine.is_editor_hint():
		# Parent should be our camera
		var parent : XRCamera3D = get_parent()
		if !parent:
			return

		var parent_transform = parent.global_transform

		# Determine forward
		var forward = -parent_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()

		# Move our label a fixed distance forward of the camera but
		# nicely horizontally aligned.
		var t : Transform3D
		t.origin = parent_transform.origin + forward * LABEL_FORWARD_DIST
		$Label3D.global_transform = t.looking_at(t.origin + forward, Vector3.UP, false)
