extends Control


# The 3D viewport's shrink factor. For instance, 1 is full resolution,
# 2 is half resolution and 4 is quarter resolution. Lower values look
# sharper but are slower to render.
var scale_factor = 1
var filter_mode = Viewport.SCALING_3D_MODE_BILINEAR

@onready var viewport = get_tree().root
@onready var scale_label = $VBoxContainer/Scale
@onready var filter_label = $VBoxContainer/Filter


func _ready():
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR


func _unhandled_input(event):
	if event.is_action_pressed("cycle_viewport_resolution"):
		scale_factor = wrapi(scale_factor + 1, 1, 5)
		viewport.scaling_3d_scale = 1.0 / scale_factor
		scale_label.text = "Scale: %3.0f%%" % (100.0 / scale_factor)

	if event.is_action_pressed("toggle_filtering"):
		filter_mode = wrapi(filter_mode + 1, Viewport.SCALING_3D_MODE_BILINEAR, Viewport.SCALING_3D_MODE_MAX) as Viewport.Scaling3DMode
		viewport.scaling_3d_mode = filter_mode
		filter_label.text = (
				ClassDB.class_get_enum_constants("Viewport", "Scaling3DMode")[filter_mode]
						.capitalize()
						.replace("3d", "3D")
						.replace("Mode", "Mode:")
						.replace("Fsr", "FSR")
		)
