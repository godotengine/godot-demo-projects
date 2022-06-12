extends Test


export(int, 1, 100) var height = 10
export(int, 1, 100) var width_max = 100
export(int, 1, 100) var depth_max = 1
export(Vector3) var box_size = Vector3(1.0, 1.0, 1.0)
export(Vector3) var box_spacing = Vector3(0.0, 0.0, 0.0)


func _ready():
	_create_pyramid()


func _create_pyramid():
	var root_node = $Pyramid

	var template_body = create_rigidbody_box(box_size, true)

	var pos_y = 0.5 * box_size.y + box_spacing.y

	for level in height:
		var level_index = height - level - 1
		var num_boxes = 2 * level_index + 1
		var num_boxes_width = min(num_boxes, width_max)
		var num_boxes_depth = min(num_boxes, depth_max)

		var row_node = Spatial.new()
		row_node.transform.origin = Vector3(0.0, pos_y, 0.0)
		row_node.name = "Row%02d" % (level + 1)
		root_node.add_child(row_node)

		var pos_x = -0.5 * (num_boxes_width - 1) * (box_size.x + box_spacing.x)

		for box_index_x in num_boxes_width:
			var pos_z = -0.5 * (num_boxes_depth - 1) * (box_size.z + box_spacing.z)

			for box_index_z in num_boxes_depth:
				var box_index = box_index_x * box_index_z
				var box = template_body.duplicate()
				box.transform.origin = Vector3(pos_x, 0.0, pos_z)
				box.name = "Box%02d" % (box_index + 1)
				row_node.add_child(box)

				pos_z += box_size.z + box_spacing.z

			pos_x += box_size.x + box_spacing.x

		pos_y += box_size.y + box_spacing.y

	template_body.queue_free()
