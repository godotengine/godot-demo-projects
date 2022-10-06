extends Control

# The 3D viewport's scale factor. For instance, 1.0 is full resolution,
# 0.5 is half resolution and 2.0 is double resolution. Higher values look
# sharper but are slower to render. Values above 1 can be used for supersampling
# (SSAA), but filtering must be enabled for supersampling to work.
var scale_factor = 1.0

@onready var viewport_container = $SubViewportContainer
@onready var viewport = $SubViewportContainer/SubViewport
@onready var scale_label = $VBoxContainer/Scale
@onready var filter_label = $VBoxContainer/Filter

func _ready():
	viewport_container.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	# Required to change the 3D viewport's size when the window is resized.
	viewport.size_changed.connect(self._root_viewport_size_changed)


func _unhandled_input(event):
	if event.is_action_pressed("cycle_viewport_resolution"):
		scale_factor = wrapf(scale_factor + 0.25, 0.25, 2.25)
		viewport.size = get_viewport().size * scale_factor
		scale_label.text = "Scale: %s%%" % str(scale_factor * 100)

	if event.is_action_pressed("toggle_filtering"):
		# Toggle the Filter flag on the ViewportTexture.
		if viewport_container.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR:
			viewport_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			filter_label.text = "Filter: Disabled"
		else:
			viewport_container.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			filter_label.text = "Filter: Enabled"


# Called when the root's viewport size changes (i.e. when the window is resized).
# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	# The viewport is resized depending on the window height.
	# To compensate for the larger resolution, the viewport sprite is scaled down.
	viewport.size = get_viewport().size * scale_factor
