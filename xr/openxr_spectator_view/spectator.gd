extends Node2D

var main_viewport: Viewport
var vr_render_size: Vector2 = Vector2()
var window_size: Vector2 = Vector2()
var hmd_view_material: ShaderMaterial

@onready var hmd_view: ColorRect = $HMDView
@onready var ui_spectator_view: OptionButton = $UI/SpectatorView
@onready var ui_track_camera: CheckBox = $UI/TrackCamera
@onready var ui_zoom_slider: HSlider = $UI/ZoomSlider
@onready var spectator_camera: Camera3D = $SpectatorCamera
@onready var stabilized_camera: Camera3D = $StabilizedCamera
@onready var vr_viewport: SubViewport = $VRSubViewport
@onready var main_scene: Node3D = $VRSubViewport/Main
@onready var start_vr = $VRSubViewport/Main/StartVR


# Update the size and position of our HMDView showing our HMD output.
func _reposition_texture_rect():
	if window_size != Vector2() and vr_render_size != Vector2():
		var size = vr_render_size * ui_zoom_slider.value
		hmd_view.size = size
		hmd_view.position = (window_size - size) * 0.5


# Called when our window size changed.
func _on_size_changed():
	# Get the new size of our window
	window_size  = get_tree().get_root().size
	_reposition_texture_rect()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get our main viewport.
	main_viewport = get_viewport()

	# Disable options not available outside of compatibility
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		ui_spectator_view.set("popup/item_2/disabled", true)
		ui_spectator_view.set("popup/item_3/disabled", true)

	# Get our hmd view material
	hmd_view_material = hmd_view.material

	# Get a signal when our window size changes
	get_tree().get_root().size_changed.connect(_on_size_changed)

	# Call at least once to initialize.
	_on_size_changed()

	# Select our default view mode.
	_on_spectator_view_item_selected(ui_spectator_view.selected)

	# Set up our tracked camera.
	_on_track_camera_toggled(ui_track_camera.button_pressed)


# Called when our OpenXR session has begun.
func _on_main_session_begun():
	vr_render_size = start_vr.get_vr_render_size()
	_reposition_texture_rect()


# User selected a new option from our view dropdown.
func _on_spectator_view_item_selected(index):
	match index:
		0: # Spectator camera
			main_viewport.disable_3d = false
			spectator_camera.visible = true
			spectator_camera.current = true
			hmd_view.visible = false
			ui_track_camera.visible = true
			ui_zoom_slider.visible = false
		1: # Stabilized
			main_viewport.disable_3d = false
			spectator_camera.visible = false
			stabilized_camera.current = true
			hmd_view.visible = false
			ui_track_camera.visible = false
			ui_zoom_slider.visible = false
		2: # Left eye
			main_viewport.disable_3d = true
			spectator_camera.visible = false
			hmd_view.visible = true
			ui_track_camera.visible = false
			ui_zoom_slider.visible = true
			if hmd_view_material:
				var vp_texture = vr_viewport.get_texture()
				hmd_view_material.set_shader_parameter(&"xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter(&"layer", 0)
		3: # Right eye
			main_viewport.disable_3d = true
			spectator_camera.visible = false
			hmd_view.visible = true
			ui_track_camera.visible = false
			ui_zoom_slider.visible = true
			if hmd_view_material:
				var vp_texture = vr_viewport.get_texture()
				hmd_view_material.set_shader_parameter(&"xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter(&"layer", 1)


# User toggled the track camera checkbox.
func _on_track_camera_toggled(toggled_on):
	if toggled_on:
		# Positioning is controlled by tracking
		spectator_camera.enable_positioning = false

		# If on, our position is controlled by a tracker.
		main_scene.tracked_camera = spectator_camera
	else:
		# If off, the user can position the camera.
		spectator_camera.enable_positioning = true
		main_scene.tracked_camera = null


# User changed the zoom slider.
func _on_zoom_slider_value_changed(_value):
	_reposition_texture_rect()
