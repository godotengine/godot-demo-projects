@tool
extends Path3D

@export var tire_spacing : float = 0.5:
	set(value):
		tire_spacing = value
		if is_inside_tree():
			_update_tires()

func _update_tires():
	var multimesh : MultiMesh = $Tirewall.multimesh

	# Cheap and dirty approach, need to improve this!
	var track_length = curve.get_baked_length()
	var tires_per_side = floor(track_length / tire_spacing)
	var offset = 0.0

	multimesh.instance_count = tires_per_side * 2
	for tire in range(tires_per_side):
		var t : Transform3D = curve.sample_baked_with_rotation(offset)

		var t_adj : Transform3D = t
		t_adj.origin += t_adj.basis.x * 5.0
		multimesh.set_instance_transform(tire, t_adj)

		t_adj = t
		t_adj.origin -= t_adj.basis.x * 5.0
		multimesh.set_instance_transform(tires_per_side + tire, t_adj)

		offset += tire_spacing

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_tires()

	if Engine.is_editor_hint():
		curve_changed.connect(_update_tires)
