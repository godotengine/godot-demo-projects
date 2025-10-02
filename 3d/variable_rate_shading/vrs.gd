extends Node3D

@onready var option_button: OptionButton = $CanvasLayer/VBoxContainer/HBoxContainer/OptionButton
@onready var texture_rect: TextureRect = $CanvasLayer/VBoxContainer/TextureRect
@onready var camera: Camera3D = $Camera3D
@onready var xr_camera: Camera3D = $XROrigin3D/XRCamera3D

@export var texture: Texture

var xr_interface: MobileVRInterface

func _set_xr_mode() -> void:
	var vrs_mode := get_viewport().vrs_mode
	if vrs_mode == Viewport.VRS_XR:
		xr_interface = XRServer.find_interface("Native mobile")
		if xr_interface and xr_interface.initialize():
			# Disable a lot of VR-specific stuff like lens distortion.
			xr_interface.eye_height = 0.0
			xr_interface.k1 = 0.0
			xr_interface.k2 = 0.0
			xr_interface.oversample = 1.0

			get_viewport().use_xr = true
			xr_camera.current = true

			# Reposition our origin point to work around an engine bug.
			$XROrigin3D.global_transform = camera.global_transform
	else:
		if xr_interface:
			xr_interface.uninitialize()

		get_viewport().use_xr = false
		camera.current = true


func _update_texture() -> void:
	var vrs_mode := get_viewport().vrs_mode
	if vrs_mode == Viewport.VRS_DISABLED:
		texture_rect.visible = false
	elif vrs_mode == Viewport.VRS_TEXTURE:
		get_viewport().vrs_texture = texture
		texture_rect.texture = texture
		texture_rect.visible = true
	elif vrs_mode == Viewport.VRS_XR:
		# Doesn't seem to be supported yet. This should be exposed in a future engine version.
		#if xr_interface:
		#	texture_rect.texture = xr_interface.get_vrs_texture()
		#	texture_rect.visible = true
		#else:
		#	texture_rect.visible = false
		texture_rect.visible = false


func _ready() -> void:
	var vrs_mode := get_viewport().vrs_mode
	option_button.selected = vrs_mode
	_update_texture()


func _on_option_button_item_selected(index: int) -> void:
	get_viewport().vrs_mode = index as Viewport.VRSMode
	_set_xr_mode()
	_update_texture()
