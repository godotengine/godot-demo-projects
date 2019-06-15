extends Panel


var paint_control

var label_tools
var label_brush_size
var label_brush_shape
var label_stats

var save_dialog


func _ready():
	# Get PaintControl and SaveFileDialog
	paint_control = get_parent().get_node("PaintControl")
	save_dialog = get_parent().get_node("SaveFileDialog")

	# warning-ignore-all:return_value_discarded
	# Assign all of the needed signals for the oppersation buttons
	get_node("ButtonUndo").connect("pressed", self, "button_pressed", ["undo_stroke"])
	get_node("ButtonSave").connect("pressed", self, "button_pressed", ["save_picture"])
	get_node("ButtonClear").connect("pressed", self, "button_pressed", ["clear_picture"])

	# Assign all of the needed signals for the brush buttons
	get_node("ButtonToolPencil").connect("pressed", self, "button_pressed", ["mode_pencil"])
	get_node("ButtonToolEraser").connect("pressed", self, "button_pressed", ["mode_eraser"])
	get_node("ButtonToolRectangle").connect("pressed", self, "button_pressed", ["mode_rectangle"])
	get_node("ButtonToolCircle").connect("pressed", self, "button_pressed", ["mode_circle"])
	get_node("ButtonShapeBox").connect("pressed", self, "button_pressed", ["shape_rectangle"])
	get_node("ButtonShapeCircle").connect("pressed", self, "button_pressed", ["shape_circle"])

	# Assign all of the needed signals for the other brush settings (and ColorPickerBackground)
	get_node("ColorPickerBrush").connect("color_changed", self, "brush_color_changed")
	get_node("ColorPickerBackground").connect("color_changed", self, "background_color_changed")
	get_node("HScrollBarBrushSize").connect("value_changed", self, "brush_size_changed")

	# Assign the 'file_selected' signal in SaveFileDialog
	save_dialog.connect("file_selected", self, "save_file_selected")

	# Get all of the labels so we can update them when settings change
	label_tools = get_node("LabelTools")
	label_brush_size = get_node("LabelBrushSize")
	label_brush_shape = get_node("LabelBrushShape")
	label_stats = get_node("LabelStats")

	# Set physics process so we can update the status label
	set_physics_process(true)


func _physics_process(_delta):
	# Update the status label with the newest brush element count
	label_stats.text = "Brush objects: " + String(paint_control.brush_data_list.size())


func button_pressed(button_name):
	# If a brush mode button is pressed
	var tool_name = null
	var shape_name = null
	
	if button_name == "mode_pencil":
		paint_control.brush_mode = paint_control.BRUSH_MODES.pencil
		tool_name = "pencil"
	elif button_name == "mode_eraser":
		paint_control.brush_mode = paint_control.BRUSH_MODES.eraser
		tool_name = "eraser"
	elif button_name == "mode_rectangle":
		paint_control.brush_mode = paint_control.BRUSH_MODES.rectangle_shape
		tool_name = "rectangle shape"
	elif button_name == "mode_circle":
		paint_control.brush_mode = paint_control.BRUSH_MODES.circle_shape
		tool_name = "circle shape"

	# If a brush shape button is pressed
	elif button_name == "shape_rectangle":
		paint_control.brush_shape = paint_control.BRUSH_SHAPES.rectangle
		shape_name = "rectangle"
	elif button_name == "shape_circle":
		paint_control.brush_shape = paint_control.BRUSH_SHAPES.circle
		shape_name = "circle";

	# If a opperation button is pressed
	elif button_name == "clear_picture":
		paint_control.brush_data_list = []
		paint_control.update()
	elif button_name == "save_picture":
		save_dialog.popup_centered()
	elif button_name == "undo_stroke":
		paint_control.undo_stroke()
	
	# Update the labels (in case the brush mode or brush shape has changed)
	if tool_name != null:
		label_tools.text = "Selected tool: " + tool_name
	if shape_name != null:
		label_brush_shape.text = "Brush shape: " + shape_name


func brush_color_changed(color):
	# Change the brush color to whatever color the color picker is
	paint_control.brush_color = color


func background_color_changed(color):
	# Change the background color to whatever colorthe background color picker is
	get_parent().get_node("DrawingAreaBG").modulate = color
	paint_control.bg_color = color
	# Because of how the eraser works we also need to redraw the paint control
	paint_control.update()


func brush_size_changed(value):
	# Change the size of the brush, and update the label to reflect the new value
	paint_control.brush_size = ceil(value)
	label_brush_size.text = "Brush size: " + String(ceil(value)) + "px"


func save_file_selected(path):
	# Call save_picture in paint_control, passing in the path we recieved from SaveFileDialog
	paint_control.save_picture(path)

