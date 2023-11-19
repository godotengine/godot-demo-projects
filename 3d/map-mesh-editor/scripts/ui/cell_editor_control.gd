class_name CellEditorControl extends Control

@export_range(0, 6, 1) var default_brush_size: int = 0
@export_range(0, 6.0, 1.0) var default_elevation: float = 0.0
@export_range(0, 6, 1) var default_terrain: int = 0

@export var btn_enable_brush: CheckBox
@export var lbl_brush_size: Label
@export var slider_brush_size: HSlider

@export var btn_enable_elevation: CheckBox
@export var lbl_elevation: Label
@export var slider_elevation: HSlider

@export var btn_enable_terrain: CheckBox
@export var btn_terrain_mtn: CheckBox
@export var btn_terrain_snow: CheckBox
@export var btn_terrain_grass: CheckBox
@export var btn_terrain_dirt: CheckBox
@export var btn_terrain_sand: CheckBox
@export var btn_terrain_mud: CheckBox

@export var btn_enable_debug: CheckBox
@export var btn_show_labels: CheckBox
@export var btn_show_wireframe: CheckBox

func _ready():
	RenderingServer.set_debug_generate_wireframes(true)
	_register_signals()
	_set_defaults()

func _register_signals():
	btn_enable_brush.toggled.connect(_on_enable_brush_toggled)
	slider_brush_size.value_changed.connect(_on_brush_size_changed)
	
	btn_enable_elevation.toggled.connect(_on_enable_elevation_toggled)
	slider_elevation.value_changed.connect(_on_elevation_changed)
	
	btn_enable_terrain.toggled.connect(_on_enable_terrain_toggled)
	btn_terrain_mtn.toggled.connect(_on_terrain_selected.bind(5, 6))
	btn_terrain_snow.toggled.connect(_on_terrain_selected.bind(4, 4))
	btn_terrain_grass.toggled.connect(_on_terrain_selected.bind(3, 3))
	btn_terrain_dirt.toggled.connect(_on_terrain_selected.bind(2, 2))
	btn_terrain_sand.toggled.connect(_on_terrain_selected.bind(1, 2))
	btn_terrain_mud.toggled.connect(_on_terrain_selected.bind(0, 0))
	
	btn_enable_debug.toggled.connect(_on_enable_debug_toggled)
	btn_show_labels.toggled.connect(_on_show_labels_toggled)
	btn_show_wireframe.toggled.connect(_on_show_wireframe_toggled)

func _set_defaults():
	GlobalCellEditor.brush_size = default_brush_size
	GlobalCellEditor.elevation = default_elevation
	GlobalCellEditor.terrain = default_terrain
	GlobalCellEditor.water = 2.0

func _on_enable_brush_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.brush_enabled = button_pressed

func _on_brush_size_changed(value: float):
	GlobalCellEditor.brush_size = value
	self.lbl_brush_size.text = str(value)

func _on_enable_elevation_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.elevation_enabled = button_pressed

func _on_elevation_changed(value: float) -> void:
	GlobalCellEditor.elevation = value
	self.lbl_elevation.text = str(value)

func _on_enable_terrain_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.terrain_enabled = button_pressed

func _on_terrain_selected(button_pressed: bool, b: int, e: float):
	if !button_pressed:
		return
	GlobalCellEditor.terrain = b
	self.slider_elevation.value = e

func _on_enable_debug_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.debug_enabled = button_pressed

func _on_show_labels_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.show_labels = button_pressed

func _on_show_wireframe_toggled(button_pressed: bool) -> void:
	GlobalCellEditor.show_wireframe = button_pressed
