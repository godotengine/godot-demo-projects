# The root Control node ("Main") and AspectRatioContainer nodes are the most important
# pieces of this demo.
# Both nodes have their Layout set to Full Rect
# (with their rect spread across the whole viewport, and Anchor set to Full Rect).
extends Control

var base_window_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

# These defaults match this demo's project settings. Adjust as needed if adapting this
# in your own project.
var stretch_mode = SceneTree.STRETCH_MODE_2D
var stretch_aspect = SceneTree.STRETCH_ASPECT_EXPAND

var scale_factor = 1.0
var gui_aspect_ratio = -1.0
var gui_margin = 0.0

onready var panel = $Panel
onready var arc = $Panel/AspectRatioContainer


func _ready():
	# The `resized` signal will be emitted when the window size changes, as the root Control node
	# is resized whenever the window size changes. This is because the root Control node
	# uses a Full Rect anchor, so its size will always be equal to the window size.
	# warning-ignore:return_value_discarded
	connect("resized", self, "_on_resized")
	update_container()


func update_container():
	# The code within this function needs to be run twice to work around an issue with containers
	# having a 1-frame delay with updates.
	# Otherwise, `panel.rect_size` returns a value of the previous frame, which results in incorrect
	# sizing of the inner AspectRatioContainer when using the Fit to Window setting.
	for _i in 2:
		if is_equal_approx(gui_aspect_ratio, -1.0):
			# Fit to Window. Tell the AspectRatioContainer to use the same aspect ratio as the window,
			# making the AspectRatioContainer not have any visible effect.
			arc.ratio = panel.rect_size.aspect()
			# Apply GUI margin on the AspectRatioContainer's parent (Panel).
			# This also makes the GUI margin apply on controls located outside the AspectRatioContainer
			# (such as the inner side label in this demo).
			panel.margin_top = gui_margin
			panel.margin_bottom = -gui_margin
		else:
			# Constrained aspect ratio.
			arc.ratio = min(panel.rect_size.aspect(), gui_aspect_ratio)
			# Adjust top and bottom margins relative to the aspect ratio when it's constrained.
			# This ensures that GUI margin settings behave exactly as if the window had the
			# original aspect ratio size.
			panel.margin_top = gui_margin / gui_aspect_ratio
			panel.margin_bottom = -gui_margin / gui_aspect_ratio

		panel.margin_left = gui_margin
		panel.margin_right = -gui_margin


func _on_gui_aspect_ratio_item_selected(index):
	match index:
		0:  # Fit to Window
			gui_aspect_ratio = -1.0
		1:  # 5:4
			gui_aspect_ratio = 5.0 / 4.0
		2:  # 4:3
			gui_aspect_ratio = 4.0 / 3.0
		3:  # 3:2
			gui_aspect_ratio = 3.0 / 2.0
		4:  # 16:10
			gui_aspect_ratio = 16.0 / 10.0
		5:  # 16:9
			gui_aspect_ratio = 16.0 / 9.0
		6:  # 21:9
			gui_aspect_ratio = 21.0 / 9.0

	update_container()


func _on_resized():
	update_container()


func _on_gui_margin_drag_ended(_value_changed):
	gui_margin = $"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/GUIMargin/HSlider".value
	$"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/GUIMargin/Value".text = str(gui_margin)
	update_container()


func _on_window_base_size_item_selected(index):
	match index:
		0:  # 648×648 (1:1)
			base_window_size = Vector2(648, 648)
		1:  # 640×480 (4:3)
			base_window_size = Vector2(640, 480)
		2:  # 720×480 (3:2)
			base_window_size = Vector2(720, 480)
		3:  # 800×600 (4:3)
			base_window_size = Vector2(800, 600)
		4:  # 1152×648 (16:9)
			base_window_size = Vector2(1152, 648)
		5:  # 1280×720 (16:9)
			base_window_size = Vector2(1280, 720)
		6:  # 1280×800 (16:10)
			base_window_size = Vector2(1280, 800)
		7:  # 1680×720 (21:9)
			base_window_size = Vector2(1680, 720)

	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, base_window_size, scale_factor)
	update_container()


func _on_window_stretch_mode_item_selected(index):
	stretch_mode = index
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, base_window_size, scale_factor)

	# Disable irrelevant options when the stretch mode is Disabled.
	$"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/WindowBaseSize/OptionButton".disabled = stretch_mode == SceneTree.STRETCH_MODE_DISABLED
	$"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/WindowStretchAspect/OptionButton".disabled = stretch_mode == SceneTree.STRETCH_MODE_DISABLED


func _on_window_stretch_aspect_item_selected(index):
	stretch_aspect = index
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, base_window_size, scale_factor)


func _on_window_scale_factor_drag_ended(_value_changed):
	scale_factor = $"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/WindowScaleFactor/HSlider".value
	$"Panel/AspectRatioContainer/ColorRect/CenterContainer/Options/WindowScaleFactor/Value".text = "%d%%" % (scale_factor * 100)
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, base_window_size, scale_factor)
