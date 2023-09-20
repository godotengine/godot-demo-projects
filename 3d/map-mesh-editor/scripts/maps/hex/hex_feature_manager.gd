class_name HexFeatureManager extends Node3D

@export_file var feature_prefab_path: String

var feature_prefab: PackedScene

var hashes: Array[HexHash] = []

func _ready():
	self.hashes.resize(16)
	for i in range(16):
		self.hashes[i] = HexHash.new()
	self.feature_prefab = load(self.feature_prefab_path)

func clear():
	for c in get_children():
		remove_child(c)

func apply():
	pass

func add_feature(cell: HexCell, pos: Vector3):
	var hash = self.hashes[randi_range(0, 15)]
	if hash.a < 0.5:
		return
	var new_feature: Node3D = self.feature_prefab.instantiate()
	new_feature.position = HexMetrics.perturb(pos)
	new_feature.rotate_y(deg_to_rad(-360.0 * hash.b))
	add_child(new_feature)
