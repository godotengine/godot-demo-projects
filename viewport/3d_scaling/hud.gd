extends Control

# The viewport is displayed using a TextureRect node instead of a ViewportContainer.
# This allows filtering the texture that's displayed in the root viewport.

# The 3D viewport's scale factor. For instance, 1.0 is full resolution,
# 0.5 is half resolution and 2.0 is double resolution. Higher values look
# sharper but are slower to render. Values above 1 can be used for supersampling
# (SSAA), but filtering must be enabled for this to work.
var scale_factor = 1.0

onready var texture_rect = $TextureRect
onready var viewport = $Viewport
onready var scale_label = $VBoxContainer/Scale
onready var filter_label = $VBoxContainer/Filter

func _ready():
	# Required to change the 3D viewport's size when the window is resized.
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")


func _unhandled_input(event):
	if event.is_action_pressed("cycle_viewport_resolution"):
		scale_factor = wrapf(scale_factor + 0.25, 0.25, 2.25)
		viewport.size = get_viewport().size * scale_factor
		scale_label.text = "Scale: %s%%" % str(scale_factor * 100)

	if event.is_action_pressed("toggle_filtering"):
		# Toggle the Filter flag on the ViewportTexture.
		texture_rect.texture.flags ^= ImageTexture.FLAG_FILTER

		var filter_enabled = texture_rect.texture.flags & ImageTexture.FLAG_FILTER
		filter_label.text = "Filter: %s" % ("Enabled" if filter_enabled else "Disabled")


# Called when the root's viewport size changes (i.e. when the window is resized).
# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	# The viewport is resized depending on the window height.
	# To compensate for the larger resolution, the viewport sprite is scaled down.
	viewport.size = get_viewport().size * scale_factor
