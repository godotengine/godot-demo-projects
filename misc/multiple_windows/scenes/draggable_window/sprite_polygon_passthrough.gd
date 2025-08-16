extends Node

@export var sprite: Sprite2D

# Call function when updating the sprite
#func _ready():
	#sprite.texture_changed.connect(generate_polygon)
	#sprite.frame_changed.connect(generate_polygon)
	#_on_sprite_texture_changed()


func generate_polygon():
	# Make a bitmap out of a sprite.
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(sprite.texture.get_image())
	# Cell size in case sprite cell is used for animation.
	var cell_size_x = float(bitmap.get_size().x) / sprite.hframes
	var cell_size_y = float(bitmap.get_size().y) / sprite.vframes
	var cell_rect: Rect2 = Rect2(cell_size_x * sprite.frame_coords.x, cell_size_y * sprite.frame_coords.y, cell_size_x, cell_size_y)
	# Grow bitmap to make sure every pixel will be captured.
	bitmap.grow_mask(1, cell_rect)
	# Generate array of polygons from bitmap.
	var bitmap_polygons: Array[PackedVector2Array] = bitmap.opaque_to_polygons(cell_rect, 1.0)
	var polygon = PackedVector2Array()
	# Offset to position polygon correctly in relation of sprite to a window.
	var offset: Vector2 = sprite.position + sprite.offset
	if sprite.centered:
		offset -= Vector2(cell_size_x, cell_size_y) / 2

	# First point is used to connect multiple polygons into one big polygon.
	var first_point: Vector2 = bitmap_polygons[0][0]
	# Uniting all polygons into polygon for window to use.
	for bitmap_polygon: PackedVector2Array in bitmap_polygons:
		for point: Vector2 in bitmap_polygon:
			polygon.append(point + offset)

		polygon.append(first_point)
		polygon.append(first_point)

	# Apply passthrough mask to the window.
	get_window().mouse_passthrough_polygon = polygon
