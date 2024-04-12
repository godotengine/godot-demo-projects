# This script creates the ImageTexture and assigns it to an existing material at runtime.
# By not having `@tool`, this avoids saving the raw image data in the scene file,
# which would make it much larger.
extends MeshInstance3D

const TEXTURE_SIZE = Vector2i(512, 512)
const GRID_SIZE = 32
const GRID_THICKNESS = 4

func _ready() -> void:
	var image := Image.create(TEXTURE_SIZE.x, TEXTURE_SIZE.y, false, Image.FORMAT_RGB8)
	# Use 1-dimensional loop as it's faster than a nested loop.
	for i in TEXTURE_SIZE.x * TEXTURE_SIZE.y:
		var x := i % TEXTURE_SIZE.y
		var y := i / TEXTURE_SIZE.y
		var color := Color()

		# Draw a grid with more contrasted points where X and Y lines meet.
		# Center the grid's lines so that lines are visible on all the texture's edges.
		if (x + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS and (y + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS:
			color.g = 0.8
		elif (x + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS or (y + GRID_THICKNESS / 2) % GRID_SIZE < GRID_THICKNESS:
			color.g = 0.25

		# Add some random noise for detail.
		color += Color(randf(), randf(), randf()) * 0.1

		image.set_pixel(x, y, color)

	image.generate_mipmaps()
	var image_texture := ImageTexture.create_from_image(image)
	get_surface_override_material(0).albedo_texture = image_texture

	image.bump_map_to_normal_map(5.0)
	image.generate_mipmaps()
	var image_texture_normal := ImageTexture.create_from_image(image)
	get_surface_override_material(0).normal_texture = image_texture_normal
