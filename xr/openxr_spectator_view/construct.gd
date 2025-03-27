extends Node2D

var vr_render_size : Vector2
var window_size : Vector2
var hmd_view_material : ShaderMaterial

@onready var tracked_camera_original_transform : Transform3D = %TrackedCamera.global_transform

func _reposition_texture_rect():
	if window_size != Vector2() and vr_render_size != Vector2():
		%HMDView.size = vr_render_size
		%HMDView.position = (window_size - vr_render_size) * 0.5


func _on_size_changed():
	# Get our hmd view material
	hmd_view_material = %HMDView.material

	# Get the new size of our window
	window_size  = get_tree().get_root().size

	# Set our container to full screen, this should update our viewport
	$SubViewportContainer.size = window_size

	_reposition_texture_rect()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get a signal when our window size changes
	get_tree().get_root().size_changed.connect(_on_size_changed)

	# Call atleast once to initialise
	_on_size_changed()

	# Select our default view mode
	_on_spectator_view_item_selected(%SpectatorView.selected)

	# Setup our tracked camera
	_on_track_camera_toggled(%TrackCamera.button_pressed)

func _on_spectator_view_item_selected(index):
	match index:
		0: # Spectator camera
			%DesktopSubViewport.disable_3d = false
			%SpectatorCamera.current = true
			%HMDView.visible = false
			%TrackCamera.visible = true
		1: # Left eye
			%DesktopSubViewport.disable_3d = true
			%HMDView.visible = true
			%TrackCamera.visible = false
			if hmd_view_material:
				var vp_texture = $VRSubViewport.get_texture()
				hmd_view_material.set_shader_parameter("xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter("layer", 0)
		2: # Right eye
			%DesktopSubViewport.disable_3d = true
			%HMDView.visible = true
			%TrackCamera.visible = false
			if hmd_view_material:
				var vp_texture = $VRSubViewport.get_texture()
				hmd_view_material.set_shader_parameter("xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter("layer", 1)


func _on_main_focus_gained():
	vr_render_size = %Main.get_vr_render_size()
	_reposition_texture_rect()


func _on_track_camera_toggled(toggled_on):
	# TODO should detect if we have camera tracking available

	if toggled_on:
		%Main.tracked_camera = %TrackedCamera
	else:
		%Main.tracked_camera = null
		%TrackedCamera.global_transform = tracked_camera_original_transform
