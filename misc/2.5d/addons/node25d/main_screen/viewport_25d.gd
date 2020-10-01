tool
extends Control

var zoom_level := 0
var is_panning = false
var pan_center: Vector2
var viewport_center: Vector2
var view_mode_index := 0

var editor_interface: EditorInterface # Set in node25d_plugin.gd
var moving = false

onready var viewport_2d = $Viewport2D
onready var viewport_overlay = $ViewportOverlay
onready var view_mode_button_group: ButtonGroup = $"../TopBar/ViewModeButtons/45Degree".group
onready var zoom_label: Label = $"../TopBar/Zoom/ZoomPercent"
onready var gizmo_25d_scene = preload("res://addons/node25d/main_screen/gizmo_25d.tscn")

func _ready():
	# Give Godot a chance to fully load the scene. Should take two frames.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var edited_scene_root = get_tree().edited_scene_root
	if !edited_scene_root:
		# Godot hasn't finished loading yet, so try loading the plugin again.
		editor_interface.set_plugin_enabled("node25d", false)
		editor_interface.set_plugin_enabled("node25d", true)
		return
	# Alright, we're loaded up. Now check if we have a valid world and assign it.
	var world_2d = edited_scene_root.get_viewport().world_2d
	if world_2d == get_viewport().world_2d:
		return # This is the MainScreen25D scene opened in the editor!
	viewport_2d.world_2d = world_2d


func _process(delta):
	if !editor_interface: # Something's not right... bail!
		return

	# View mode polling.
	var view_mode_changed_this_frame = false
	var new_view_mode = view_mode_button_group.get_pressed_button().get_index()
	if view_mode_index != new_view_mode:
		view_mode_index = new_view_mode
		view_mode_changed_this_frame = true
		_recursive_change_view_mode(get_tree().edited_scene_root)

	# Zooming.
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
		zoom_level += 1
	elif Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
		zoom_level -= 1
	var zoom = _get_zoom_amount()

	# Viewport size.
	var size = get_global_rect().size
	viewport_2d.size = size

	# Viewport transform.
	var viewport_trans = Transform2D.IDENTITY
	viewport_trans.x *= zoom
	viewport_trans.y *= zoom
	viewport_trans.origin = viewport_trans.basis_xform(viewport_center) + size / 2
	viewport_2d.canvas_transform = viewport_trans
	viewport_overlay.canvas_transform = viewport_trans

	# Delete unused gizmos.
	var selection = editor_interface.get_selection().get_selected_nodes()
	var overlay_children = viewport_overlay.get_children()
	for overlay_child in overlay_children:
		var contains = false
		for selected in selection:
			if selected == overlay_child.node_25d and !view_mode_changed_this_frame:
				contains = true
		if !contains:
			overlay_child.queue_free()

	# Add new gizmos.
	for selected in selection:
		if selected is Node25D:
			var new = true
			for overlay_child in overlay_children:
				if selected == overlay_child.node_25d:
					new = false
			if new:
				var gizmo = gizmo_25d_scene.instance()
				viewport_overlay.add_child(gizmo)
				gizmo.node_25d = selected
				gizmo.initialize()


# This only accepts input when the mouse is inside of the 2.5D viewport.
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom_level += 1
				accept_event()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom_level -= 1
				accept_event()
			elif event.button_index == BUTTON_MIDDLE:
				is_panning = true
				pan_center = viewport_center - event.position
				accept_event()
			elif event.button_index == BUTTON_LEFT:
				var overlay_children = viewport_overlay.get_children()
				for overlay_child in overlay_children:
					overlay_child.wants_to_move = true
				accept_event()
		elif event.button_index == BUTTON_MIDDLE:
			is_panning = false
			accept_event()
		elif event.button_index == BUTTON_LEFT:
			var overlay_children = viewport_overlay.get_children()
			for overlay_child in overlay_children:
				overlay_child.wants_to_move = false
			accept_event()
	elif event is InputEventMouseMotion:
		if is_panning:
			viewport_center = pan_center + event.position
			accept_event()


func _recursive_change_view_mode(current_node):
	if current_node.has_method("set_view_mode"):
		current_node.set_view_mode(view_mode_index)
	for child in current_node.get_children():
		_recursive_change_view_mode(child)


func _get_zoom_amount():
	var zoom_amount = pow(1.05476607648, zoom_level) # 13th root of 2
	zoom_label.text = str(round(zoom_amount * 1000) / 10) + "%"
	return zoom_amount


func _on_ZoomOut_pressed():
	zoom_level -= 1


func _on_ZoomIn_pressed():
	zoom_level += 1


func _on_ZoomReset_pressed():
	zoom_level = 0
