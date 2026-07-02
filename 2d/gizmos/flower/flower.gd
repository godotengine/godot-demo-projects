@tool
class_name Flower
extends Node2D

## This holds the amount and transforms of the petals
@export_storage var _petals:Array[Transform2D] = []

## The radius of the flower disk.
@export var radius:float = 100:
	set(value):
		radius = max(0, value)
		_repaint()
		
## The color of the flower disk.
@export var disk_color:Color = Color.BROWN:
	set(value):
		disk_color = value
		_repaint()
		
## The color of the petals.
@export var petal_color:Color = Color.YELLOW:
	set(value):
		petal_color = value
		_repaint()

## Tool button to add a new petal to the flower.
@export_tool_button("Add petal") var add_petal:Callable = _add_petal
## Tool button to remove a petal from the flower.
@export_tool_button("Remove petal") var remove_petal:Callable = _remove_petal
## Tool button to rearrange all petals to the default layout.
@export_tool_button("Arrange petals") var arrange_petals:Callable = _arrange_petals

## The child circle node which we use to draw the core.
var _disk_circle:Circle
## The child circle nodes which we use to draw the petals.
var _petal_circles:Array[Circle] = []

func _ready() -> void:
	_repaint()

## Adds a new petal to the flower.
func _add_petal() -> void:
	var new_petals:Array[Transform2D] = _petals.duplicate()
	var angle:float = TAU / float(_petals.size() + 1)
	
	new_petals.append(
		Transform2D()
			.scaled(Vector2(0.5, 1))
			.translated(Vector2(0, 1.75 * radius)) 
			.rotated(_petals.size() * angle)
		)
	# We handle undo/redo code in a single place, so we call that here.
	_set_petals("Add petal", new_petals)
	
## Removes a petal from the flower. If the flower has no petals
## does nothing.
func _remove_petal() -> void:
	if _petals.size() > 0:
		_set_petals("Remove petal", _petals.slice(0, -1))
		
## Arranges the petals of the flower in the default style.		
func _arrange_petals() -> void:
	if _petals.is_empty():
		return
		
	var angle:float = TAU / float(_petals.size())
	var new_petals:Array[Transform2D] = []
	
	for i in _petals.size():
		new_petals.append(
			Transform2D() 
				.scaled(Vector2(0.5, 1)) 
				.translated(Vector2(0, 1.75 * radius)) 
				.rotated(i * angle)
		)

	_set_petals("Arrange petals", new_petals)
	
## Updates petal transforms and provides undo/redo support for this in the editor.	
func _set_petals(description:String, new_petals:Array[Transform2D]) -> void:
	if Engine.is_editor_hint():
		# When called inside the editor, we do proper undo/redo.
		var undo_redo:EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action(description)
		undo_redo.add_do_property(self, "_petals", new_petals)
		undo_redo.add_do_method(self, "_repaint")
		undo_redo.add_undo_property(self, "_petals", _petals)
		undo_redo.add_undo_method(self, "_repaint")
		undo_redo.commit_action()
	else:
		# Outside the editor, just apply the new value and repaint.
		_petals = new_petals
		_repaint()
	
		
## Updates the circle nodes we use to draw the petals.	
func _repaint() -> void:
	# Ensure we have a disk circle child node
	if not is_instance_valid(_disk_circle):
		_disk_circle = Circle.new()
		add_child(_disk_circle)
		
	# Update disk size and color
	_disk_circle.color = disk_color
	_disk_circle.radius = radius
	_disk_circle.z_index = 1
	
	for i in _petals.size():
		# Ensure we have a circle for that petal
		if _petal_circles.size() <= i:
			var circle:Circle = Circle.new()
			add_child(circle)
			_petal_circles.append(circle)

		# Update petal color, size and positioning
		_petal_circles[i].color = petal_color
		_petal_circles[i].radius = radius
		_petal_circles[i].transform = _petals[i]
		
	# Remove any extra petal circles we may have
	while _petal_circles.size() > _petals.size():
		var circle:Circle = _petal_circles.pop_back()
		circle.queue_free()
			
