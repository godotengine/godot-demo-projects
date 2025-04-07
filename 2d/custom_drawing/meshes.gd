# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false


func _draw() -> void:
	var margin := Vector2(300, 70)

	var offset := Vector2()
	var text_mesh := TextMesh.new()
	text_mesh.text = "TextMesh"
	# In 2D, 1 unit equals 1 pixel, so the default size at which PrimitiveMeshes are displayed is tiny.
	# Use much larger mesh size to compensate, or use `draw_set_transform()` before using `draw_mesh()`
	# to scale the draw command.
	text_mesh.pixel_size = 2.5

	var noise_texture := NoiseTexture2D.new()
	noise_texture.seamless = true
	noise_texture.as_normal_map = true
	noise_texture.noise = FastNoiseLite.new()

	# FIXME: The mesh needs to be added to a MeshInstance2D (even out-of-tree)
	# for it to be usable in `draw_mesh()` (otherwise, nothing appears and an error is printed).
	# Same goes for the texture. I don't know why.
	var mi2d := MeshInstance2D.new()
	mi2d.mesh = text_mesh
	mi2d.texture = noise_texture

	var mi2d2 := MeshInstance2D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.height = 80.0
	sphere_mesh.radius = 40.0
	mi2d2.mesh = sphere_mesh
	mi2d2.texture = noise_texture

	# `draw_set_transform()` is a stateful command: it affects *all* `draw_` methods within this
	# `_draw()` function after it. This can be used to translate, rotate or scale `draw_` methods
	# that don't offer dedicated parameters for this (such as `draw_primitive()` not having a position parameter).
	# To reset back to the initial transform, call `draw_set_transform(Vector2())`.
	#
	# Flip drawing on the Y axis so the text appears upright.
	draw_set_transform(margin + offset, 0.0, Vector2(1, -1))
	draw_mesh(text_mesh, noise_texture)

	offset += Vector2(150, 0)
	draw_set_transform(margin + offset)
	draw_mesh(sphere_mesh, noise_texture)

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = Gradient.new()
	var multi_mesh := MultiMesh.new()
	multi_mesh.use_colors = true
	multi_mesh.instance_count = 5
	multi_mesh.set_instance_transform_2d(0, Transform2D(0.0, Vector2(0, 0)))
	multi_mesh.set_instance_color(0, Color(1, 0.7, 0.7))
	multi_mesh.set_instance_transform_2d(1, Transform2D(0.0, Vector2(0, 100)))
	multi_mesh.set_instance_color(1, Color(0.7, 1, 0.7))
	multi_mesh.set_instance_transform_2d(2, Transform2D(0.0, Vector2(100, 100)))
	multi_mesh.set_instance_color(2, Color(0.7, 0.7, 1))
	multi_mesh.set_instance_transform_2d(3, Transform2D(0.0, Vector2(100, 0)))
	multi_mesh.set_instance_color(3, Color(1, 1, 0.7))
	multi_mesh.set_instance_transform_2d(4, Transform2D(0.0, Vector2(50, 50)))
	multi_mesh.set_instance_color(4, Color(0.7, 1, 1))
	multi_mesh.mesh = sphere_mesh
	var mmi2d := MultiMeshInstance2D.new()
	mmi2d.multimesh = multi_mesh
	mmi2d.texture = gradient_texture

	# FIXME: The multimesh needs to be added to a MultiMeshInstance2D (even out-of-tree)
	# for it to be usable in `draw_multimesh()` (otherwise, it crashes).
	# Same goes for the texture. I don't know why.
	offset = Vector2(0, 120)
	draw_set_transform(margin + offset)
	draw_multimesh(multi_mesh, gradient_texture)
