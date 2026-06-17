extends Node


@export var drawing_canvas: TextureRect
@export var cube: MeshInstance3D
@export var sphere: MeshInstance3D

@export var color_rects: Array[ColorRect]
@export var godot_stamp: TextureRect
@export var brush_size_slider: HSlider

var drawable_texture: DrawableTexture2D
var brush: GradientTexture2D
var godot_brush: CompressedTexture2D
var eraser: GradientTexture2D

var background_color: Color = Color.WHITE

## A way to check if we're using the Godot stamp or normal brush.
var brush_mode: bool = true


func _ready() -> void:
	# First we create & set up the drawable texure. After that we can attach it
	# to the nodes we want such as the texture rect and the albedo texture
	# for our mesh instance 3D cube.
	drawable_texture = DrawableTexture2D.new()
	drawable_texture.setup(500, 500, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8)

	(cube.get_active_material(0) as StandardMaterial3D).albedo_texture = drawable_texture
	drawing_canvas.texture = drawable_texture

	# Creating a "brush".
	brush = GradientTexture2D.new()
	brush.fill = GradientTexture2D.FILL_RADIAL
	brush.fill_from = Vector2(0.5, 0.5)
	brush.fill_to = Vector2(0.5, 1.0)

	# Setting black as the default color for the brush.
	brush.gradient = Gradient.new()
	brush.gradient.set_color(0, Color.BLACK)
	brush.gradient.set_color(1, Color(0,0,0,0)) # Fading edges.

	# Creating the "eraser" as just another "brush" but with the background
	# color to fake the erasing effect.
	eraser = GradientTexture2D.new()
	eraser.fill = GradientTexture2D.FILL_RADIAL
	eraser.fill_from = Vector2(0.5, 0.5)
	eraser.fill_to = Vector2(0.5, 1.0)
	eraser.gradient = Gradient.new()
	eraser.gradient.set_color(0, background_color)
	eraser.gradient.set_color(1, Color(background_color, 0.0)) # Fading edges.

	godot_brush = preload("res://icon_brush.svg")

	brush_size_slider.value = 64

	# Connecting the color rects so they can be used to change the color.
	for color_rect: ColorRect in color_rects:
		color_rect.gui_input.connect(change_brush_color.bind(color_rect.color))
	godot_stamp.gui_input.connect(change_brush_to_godot)


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_paint_at(event.position, false)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_paint_at(event.position, true)


#--- Painting logic ---

func _paint_at(pos: Vector2, erase: bool) -> void:
	# Execute the GPU blit.
	var brush_size = Vector2i(brush.width, brush.height)
	var top_left = Vector2(pos) - (brush_size / 2.0)
	var rect = Rect2i(top_left, brush_size)

	if brush_mode:
		drawable_texture.blit_rect(rect, eraser if erase else brush, Color.WHITE, 0, null)
	else:
		drawable_texture.blit_rect(rect, godot_brush, Color.WHITE, 0, null)


#--- Color changing buttons + brush size changing functions ---

func change_brush_color(event: InputEvent, color: Color) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.is_pressed():
			brush.gradient.set_color(0, color)
			brush.gradient.set_color(1, Color(color, 0.0))
			print("Brush changed to color: ", color)
			brush_mode = true


func change_brush_to_godot(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.is_pressed():
			brush_mode = false
			print("Brush changed to Godot")


func _on_size_h_slider_value_changed(value: float) -> void:
	var size: int = int(value)
	brush.width = size
	brush.height = size
	eraser.width = size
	eraser.height = size
	print("Brush size to: ", size)


#--- 3D scene buttons for switching visible mesh instance ---

func _on_cube_button_pressed() -> void:
	cube.visible = true
	sphere.visible = false


func _on_sphere_button_pressed() -> void:
	cube.visible = false
	sphere.visible = true
