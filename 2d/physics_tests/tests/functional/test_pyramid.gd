extends Test


export(int, 1, 100) var height = 10
export(Vector2) var box_size = Vector2(40.0, 40.0)
export(Vector2) var box_spacing =  Vector2(0.0, 0.0)


func _ready():
	_create_pyramid()


func _create_pyramid():
	var root_node = $Pyramid

	var template_body = create_rigidbody_box(box_size, true)

	var pos_y = -0.5 * box_size.y - box_spacing.y

	for level in height:
		var level_index = height - level - 1
		var num_boxes = 2 * level_index + 1

		var row_node = Node2D.new()
		row_node.position = Vector2(0.0, pos_y)
		row_node.name = "Row%02d" % (level + 1)
		root_node.add_child(row_node)

		var pos_x = -0.5 * (num_boxes - 1) * (box_size.x + box_spacing.x)

		for box_index in range(num_boxes):
			var box = template_body.duplicate()
			box.position = Vector2(pos_x, 0.0)
			box.name = "Box%02d" % (box_index + 1)
			row_node.add_child(box)

			pos_x += box_size.x + box_spacing.x

		pos_y -= box_size.y + box_spacing.y

	template_body.queue_free()
