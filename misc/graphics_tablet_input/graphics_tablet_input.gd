extends Control

# Automatically split lines at regular intervals to avoid performance issues
# while drawing. This is especially due to the width curve which has to be recreated
# on every new point.
const SPLIT_POINT_COUNT = 1024

var stroke: Line2D
var width_curve: Curve
var pressures := PackedFloat32Array()
var event_position: Vector2
var event_tilt: Vector2

var line_color := Color.BLACK
var line_width: float = 3.0

# If `true`, modulate line width accordding to pen pressure.
# This is done using a width curve that is continuously recreated to match the line's actual profile
# as the line is being drawn by the user.
var pressure_sensitive: bool = true

var show_tilt_vector: bool = true

@onready var tablet_info: Label = %TabletInfo


func _ready() -> void:
	# This makes tablet and mouse input reported as often as possible regardless of framerate.
	# When accumulated input is disabled, we can query the pen/mouse position at every input event
	# seen by the operating system, without being limited to the framerate the application runs at.
	# The downside is that this uses more CPU resources, so input accumulation should only be
	# disabled when you need to have access to precise input coordinates.
	Input.use_accumulated_input = false
	start_stroke()
	%TabletDriver.text = "Tablet driver: %s" % DisplayServer.tablet_get_current_driver()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_pressed(&"increase_line_width"):
			$CanvasLayer/PanelContainer/Options/LineWidth/HSlider.value += 0.5
			#_on_line_width_value_changed(line_width)
		if Input.is_action_pressed(&"decrease_line_width"):
			$CanvasLayer/PanelContainer/Options/LineWidth/HSlider.value -= 0.5
			#_on_line_width_value_changed(line_width)

	if not stroke:
		return

	if event is InputEventMouseMotion:
		var event_mouse_motion := event as InputEventMouseMotion
		tablet_info.text = "Pressure: %.3f\nTilt: %.3v\nInverted pen: %s" % [
			event_mouse_motion.pressure,
			event_mouse_motion.tilt,
			"Yes" if event_mouse_motion.pen_inverted else "No",
		]

		if event_mouse_motion.pressure <= 0 and stroke.points.size() > 1:
			# Initial part of a stroke; create a new line.
			start_stroke()
			# Enable the buttons if they were previously disabled.
			%ClearAllLines.disabled = false
			%UndoLastLine.disabled = false
		if event_mouse_motion.pressure > 0:
			# Continue existing line.
			stroke.add_point(event_mouse_motion.position)
			pressures.push_back(event_mouse_motion.pressure)
			# Only compute the width curve if it's present, as it's not even created
			# if pressure sensitivity is disabled.
			if width_curve:
				width_curve.clear_points()
				for pressure_idx in range(pressures.size()):
					width_curve.add_point(Vector2(
							float(pressure_idx) / pressures.size(),
							pressures[pressure_idx]
					))

			# Split into a new line if it gets too long to avoid performance issues.
			# This is mostly reached when input accumulation is disabled, as enabling
			# input accumulation will naturally reduce point count by a lot.
			if stroke.get_point_count() >= SPLIT_POINT_COUNT:
				start_stroke()

		event_position = event_mouse_motion.position
		event_tilt = event_mouse_motion.tilt
		queue_redraw()


func _draw() -> void:
	if show_tilt_vector:
		# Draw tilt vector.
		draw_line(event_position, event_position + event_tilt * 50, Color(1, 0, 0, 0.5), 2, true)


func start_stroke() -> void:
	var new_stroke := Line2D.new()
	new_stroke.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_stroke.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_stroke.joint_mode = Line2D.LINE_JOINT_ROUND
	# Adjust round precision depending on line width to improve performance
	# and ensure it doesn't go above the default.
	new_stroke.round_precision = mini(line_width, 8)
	new_stroke.default_color = line_color
	new_stroke.width = line_width
	if pressure_sensitive:
		new_stroke.width_curve = Curve.new()
	add_child(new_stroke)

	new_stroke.owner = self
	stroke = new_stroke
	if pressure_sensitive:
		width_curve = new_stroke.width_curve
	else:
		width_curve = null
	pressures.clear()


func _on_undo_last_line_pressed() -> void:
	# Remove last node of type Line2D in the scene.
	var last_line_2d: Line2D = find_children("", "Line2D")[-1]
	if last_line_2d:
		# Remove stray empty line present at the end due to mouse motion.
		# Note that doing it once doesn't always suffice, as multiple empty lines
		# may exist at the end of the list (e.g. after changing line width/color settings).
		# In this case, the user will have to use undo multiple times.
		if last_line_2d.get_point_count() == 0:
			last_line_2d.queue_free()

			var other_last_line_2d: Line2D = find_children("", "Line2D")[-2]
			if other_last_line_2d:
				other_last_line_2d.queue_free()
		else:
			last_line_2d.queue_free()

		# Since a new line is created as soon as mouse motion occurs (even if nothing is visible yet),
		# we consider the list of lines to be empty with up to 2 items in it here.
		%UndoLastLine.disabled = find_children("", "Line2D").size() <= 2
		start_stroke()


func _on_clear_all_lines_pressed() -> void:
	# Remove all nodes of type Line2D in the scene.
	for node in find_children("", "Line2D"):
		node.queue_free()

	%ClearAllLines.disabled = true
	start_stroke()


func _on_line_color_changed(color: Color) -> void:
	line_color = color
	# Required to make the setting change apply immediately.
	start_stroke()

func _on_line_width_value_changed(value: float) -> void:
	line_width = value
	$CanvasLayer/PanelContainer/Options/LineWidth/Value.text = "%.1f" % value
	# Required to make the setting change apply immediately.
	start_stroke()


func _on_pressure_sensitive_toggled(toggled_on: bool) -> void:
	pressure_sensitive = toggled_on
	# Required to make the setting change apply immediately.
	start_stroke()


func _on_show_tilt_vector_toggled(toggled_on: bool) -> void:
	show_tilt_vector = toggled_on


func _on_msaa_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA


func _on_max_fps_value_changed(value: float) -> void:
	# Since the project has low-processor usage mode enabled, we change its sleep interval instead.
	# Since this is a value in microseconds between frames, we have to convert it from a FPS value.
	@warning_ignore("narrowing_conversion")
	OS.low_processor_usage_mode_sleep_usec = 1_000_000.0 / value
	$CanvasLayer/PanelContainer/Options/MaxFPS/Value.text = str(roundi(value))


func _on_v_sync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)


func _on_input_accumulation_toggled(toggled_on: bool) -> void:
	Input.use_accumulated_input = toggled_on
