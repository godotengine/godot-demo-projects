extends Panel

@onready var brush_settings = $BrushSettings
@onready var label_brush_size = brush_settings.get_node(^"LabelBrushSize")
@onready var label_brush_shape = brush_settings.get_node(^"LabelBrushShape")
@onready var label_stats = $LabelStats
@onready var label_tools = $LabelTools

@onready var _parent = get_parent()
@onready var save_dialog = _parent.get_node(^"SaveFileDialog")
@onready var paint_control = _parent.get_node(^"PaintControl")

func _ready():
	# Assign all of the needed signals for the oppersation buttons.
	$ButtonUndo.pressed.connect(button_pressed.bind("undo_stroke"))
	$ButtonSave.pressed.connect(button_pressed.bind("save_picture"))
	$ButtonClear.pressed.connect(button_pressed.bind("clear_picture"))

	# Assign all of the needed signals for the brush buttons.
	$ButtonToolPencil.pressed.connect(button_pressed.bind("mode_pencil"))
	$ButtonToolEraser.pressed.connect(button_pressed.bind("mode_eraser"))
	$ButtonToolRectangle.pressed.connect(button_pressed.bind("mode_rectangle"))
	$ButtonToolCircle.pressed.connect(button_pressed.bind("mode_circle"))
	$BrushSettings/ButtonShapeBox.pressed.connect(button_pressed.bind("shape_rectangle"))
	$BrushSettings/ButtonShapeCircle.pressed.connect(button_pressed.bind("shape_circle"))

	# Assign all of the needed signals for the other brush settings (and ColorPickerBackground).
	$ColorPickerBrush.color_changed.connect(brush_color_changed)
	$ColorPickerBackground.color_changed.connect(background_color_changed)
	$BrushSettings/HScrollBarBrushSize.value_changed.connect(brush_size_changed)

	# Assign the "file_selected" signal in SaveFileDialog.
	save_dialog.file_selected.connect(save_file_selected)

	# Set physics process so we can update the status label.
	set_physics_process(true)


func _physics_process(_delta):
	# Update the status label with the newest brush element count.
	label_stats.text = "Brush objects: " + str(paint_control.brush_data_list.size())


func button_pressed(button_name):
	# If a brush mode button is pressed.
	var tool_name = null
	var shape_name = null

	if button_name == "mode_pencil":
		paint_control.brush_mode = paint_control.BrushModes.PENCIL
		brush_settings.modulate = Color(1, 1, 1, 1)
		tool_name = "Pencil"
	elif button_name == "mode_eraser":
		paint_control.brush_mode = paint_control.BrushModes.ERASER
		brush_settings.modulate = Color(1, 1, 1, 1)
		tool_name = "Eraser"
	elif button_name == "mode_rectangle":
		paint_control.brush_mode = paint_control.BrushModes.RECTANGLE_SHAPE
		brush_settings.modulate = Color(1, 1, 1, 0.5)
		tool_name = "Rectangle shape"
	elif button_name == "mode_circle":
		paint_control.brush_mode = paint_control.BrushModes.CIRCLE_SHAPE
		brush_settings.modulate = Color(1, 1, 1, 0.5)
		tool_name = "Circle shape"

	# If a brush shape button is pressed
	elif button_name == "shape_rectangle":
		paint_control.brush_shape = paint_control.BrushShapes.RECTANGLE
		shape_name = "Rectangle"
	elif button_name == "shape_circle":
		paint_control.brush_shape = paint_control.BrushShapes.CIRCLE
		shape_name = "Circle";

	# If a opperation button is pressed
	elif button_name == "clear_picture":
		paint_control.brush_data_list = []
		paint_control.queue_redraw()
	elif button_name == "save_picture":
		save_dialog.popup_centered()
	elif button_name == "undo_stroke":
		paint_control.undo_stroke()

	# Update the labels (in case the brush mode or brush shape has changed).
	if tool_name != null:
		label_tools.text = "Selected tool: " + tool_name
	if shape_name != null:
		label_brush_shape.text = "Brush shape: " + shape_name


func brush_color_changed(color):
	# Change the brush color to whatever color the color picker is.
	paint_control.brush_color = color


func background_color_changed(color):
	# Change the background color to whatever colorthe background color picker is.
	get_parent().get_node(^"DrawingAreaBG").modulate = color
	paint_control.bg_color = color
	# Because of how the eraser works we also need to redraw the paint control.
	paint_control.queue_redraw()


func brush_size_changed(value):
	# Change the size of the brush, and update the label to reflect the new value.
	paint_control.brush_size = ceil(value)
	label_brush_size.text = "Brush size: " + str(ceil(value)) + "px"


func save_file_selected(path):
	# Call save_picture in paint_control, passing in the path we recieved from SaveFileDialog.
	paint_control.save_picture(path)
