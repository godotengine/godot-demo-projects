extends Node3D

const NUM_TREE_CLUSTERS = 2000
const SPREAD = 1250
const TREE_CLUSTER_SCENE = preload("res://tree_cluster.tscn")

## If `false`, highest detail is always used (slower).
var visibility_ranges_enabled = true

## `true` = use transparencdy fade, `false` = use hysteresis.
var fade_mode_enabled = true

func _ready():
	for i in 2:
		# Draw two frames to let the loading screen be visible.
		await get_tree().process_frame

	# Use a predefined random seed for better reproducibility of results.
	seed(0x60d07)

	for i in NUM_TREE_CLUSTERS:
		var tree_cluster = TREE_CLUSTER_SCENE.instantiate()
		tree_cluster.position = Vector3(randf_range(-SPREAD, SPREAD), 0, randf_range(-SPREAD, SPREAD))
		add_child(tree_cluster)

	$Loading.visible = false


func _input(event):
	if event.is_action_pressed(&"toggle_visibility_ranges"):
		visibility_ranges_enabled = not visibility_ranges_enabled
		$VisibilityRanges.text = "Visibility ranges: %s" % ("Enabled" if visibility_ranges_enabled else "Disabled")
		$VisibilityRanges.modulate = Color.WHITE if visibility_ranges_enabled else Color.YELLOW
		$FadeMode.visible = visibility_ranges_enabled

		# When disabling visibility ranges, display the high-detail trees at any range.
		for node in get_tree().get_nodes_in_group(&"tree_high_detail"):
			if visibility_ranges_enabled:
				node.visibility_range_begin = 0
				node.visibility_range_end = 20
			else:
				node.visibility_range_begin = 0
				node.visibility_range_end = 0
		for node in get_tree().get_nodes_in_group(&"tree_low_detail"):
			node.visible = visibility_ranges_enabled
		for node in get_tree().get_nodes_in_group(&"tree_cluster_high_detail"):
			node.visible = visibility_ranges_enabled
		for node in get_tree().get_nodes_in_group(&"tree_cluster_low_detail"):
			node.visible = visibility_ranges_enabled

	if event.is_action_pressed(&"toggle_fade_mode"):
		fade_mode_enabled = not fade_mode_enabled
		$FadeMode.text = "Fade mode: %s" % ("Enabled (Transparency)" if fade_mode_enabled else "Disabled (Hysteresis)")

		for node in get_tree().get_nodes_in_group(&"tree_high_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED

		for node in get_tree().get_nodes_in_group(&"tree_low_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_end_margin = 50
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_end_margin = 0

		for node in get_tree().get_nodes_in_group(&"tree_cluster_high_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_begin_margin = 50
				node.visibility_range_end_margin = 50
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_begin_margin = 0
				node.visibility_range_end_margin = 0

		for node in get_tree().get_nodes_in_group(&"tree_cluster_low_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_end_margin = 100
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_end_margin = 0
