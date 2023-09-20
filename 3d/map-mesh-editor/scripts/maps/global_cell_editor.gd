extends Node

var brush_enabled: bool = true
var brush_size: int = 0

var elevation_enabled: bool = true
var elevation: int = 0

var terrain_enabled: bool = true
var terrain: int = 2

var water_enabled: bool = false
var water: int = 2

var debug_enabled: bool = true :
	get:
		return debug_enabled
	set(value):
		debug_enabled = value
		_refresh_debug()
		
var show_labels: bool = false :
	get:
		return show_labels
	set(value):
		show_labels = value
		emit_signal("show_labels_updated")

var show_wireframe: bool = false :
	get:
		return show_wireframe
	set(value):
		show_wireframe = value and self.debug_enabled
		var vp = get_viewport()
		if value and show_wireframe:
			vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		else:
			vp.debug_draw = Viewport.DEBUG_DRAW_DISABLED

signal show_labels_updated

func reset() -> void:
	self.brush_enabled = true
	self.brush_size = 0
	
	self.elevation_enabled = true
	self.elevation = 0
	
	self.terrain_enabled = true
	self.terrain = 2
	
	self.debug_enabled = true
	self.show_labels = false
	self.show_wireframe = false

func _refresh_debug() -> void:
	self.show_labels = self.show_labels
	self.show_wireframe = self.show_wireframe
