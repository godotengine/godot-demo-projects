extends Control

const CAMERA_DEACTIVATION_DELAY := 0.1
const DISPLAY_PADDING := 40.0
const DEFAULT_WEB_RESOLUTION: Dictionary = {"width": 640, "height": 480}

enum ShaderMode { RGB = 0, YCBCR_SEP = 1, YCBCR = 2 }

@onready var camera_display := $CameraDisplay
@onready var mirror_container := $CameraDisplay/MirrorContainer
@onready var rotation_container := $CameraDisplay/MirrorContainer/RotationContainer
@onready var aspect_container := $CameraDisplay/MirrorContainer/RotationContainer/AspectContainer
@onready var camera_preview := $CameraDisplay/MirrorContainer/RotationContainer/AspectContainer/CameraPreview
@onready var camera_list := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/CameraList
@onready var format_list := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/FormatList
@onready var start_or_stop_button := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/ButtonContainer/StartOrStopButton
@onready var reload_button := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/ButtonContainer/ReloadButton

var camera_feed: CameraFeed
var _initialized := false
var _cached_formats: Array = []
var _last_feed_transform: Transform2D
var _texture_initialized := false

func _ready() -> void:
	_adjust_ui()
	_reload_camera_list()
	_initialized = true


func _adjust_ui() -> void:
	camera_display.size = camera_display.get_parent_area_size() - Vector2.ONE * DISPLAY_PADDING

	var saved_mirror_scale: Vector2 = mirror_container.scale if mirror_container else Vector2.ONE
	var saved_rotation: float = rotation_container.rotation if rotation_container else 0.0

	if mirror_container:
		mirror_container.scale = Vector2.ONE
		mirror_container.pivot_offset = mirror_container.size / 2
		mirror_container.scale = saved_mirror_scale

	if rotation_container:
		rotation_container.rotation = 0.0
		rotation_container.pivot_offset = rotation_container.size / 2
		rotation_container.rotation = saved_rotation

	if camera_display.resized.is_connected(_adjust_ui):
		camera_display.resized.disconnect(_adjust_ui)
	camera_display.resized.connect(_adjust_ui, ConnectFlags.CONNECT_ONE_SHOT)


func _reload_camera_list() -> void:
	camera_list.clear()
	format_list.clear()

	# Request camera permission on Android
	if OS.get_name() == "Android":
		if not "CAMERA" in OS.get_granted_permissions():
			if not OS.request_permission("CAMERA"):
				print("CAMERA permission not granted")
				return

	if CameraServer.is_monitoring_feeds:
		CameraServer.monitoring_feeds = false
		await get_tree().process_frame

	if not CameraServer.camera_feeds_updated.is_connected(_on_camera_feeds_updated):
		CameraServer.camera_feeds_updated.connect(_on_camera_feeds_updated, ConnectFlags.CONNECT_DEFERRED)

	CameraServer.monitoring_feeds = true


func _on_camera_feeds_updated() -> void:
	var feeds := CameraServer.feeds()

	# Skip if feed list hasn't changed
	if feeds.size() == camera_list.item_count:
		var all_match := true
		for i in feeds.size():
			if feeds[i].get_name() != camera_list.get_item_text(i):
				all_match = false
				break
		if all_match:
			return

	camera_list.clear()
	format_list.clear()

	if feeds.is_empty():
		camera_list.add_item("No cameras found")
		camera_list.disabled = true
		format_list.add_item("No formats available")
		format_list.disabled = true
		start_or_stop_button.disabled = true
		return

	camera_list.disabled = false
	for feed: CameraFeed in feeds:
		camera_list.add_item(feed.get_name())

	_on_camera_list_item_selected(camera_list.selected)


func _on_camera_list_item_selected(index: int) -> void:
	var camera_feeds := CameraServer.feeds()
	if index < 0 or index >= camera_feeds.size():
		return

	# Stop previous camera and wait for hardware to fully deactivate
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
		await get_tree().create_timer(CAMERA_DEACTIVATION_DELAY).timeout

	camera_feed = camera_feeds[index]
	_cached_formats = []
	await _update_format_list()


func _update_format_list() -> void:
	format_list.clear()

	if not camera_feed:
		return

	_cached_formats = camera_feed.get_formats()
	if _cached_formats.is_empty():
		format_list.add_item("No formats available")
		format_list.disabled = true
		start_or_stop_button.disabled = true
		return

	format_list.disabled = false
	start_or_stop_button.disabled = false
	for format: Dictionary in _cached_formats:
		var width: int = format.get("width", 0)
		var height: int = format.get("height", 0)
		var format_name: String = format.get("format", "Unknown")
		var item := "%s - %dx%d" % [format_name, width, height]

		if format.has("frame_denominator") and format.has("frame_numerator"):
			item += " : %s / %s" % [format["frame_numerator"], format["frame_denominator"]]
		elif format.has("framerate_denominator") and format.has("framerate_numerator"):
			item += " : %s / %s" % [format["framerate_numerator"], format["framerate_denominator"]]
		format_list.add_item(item)

	format_list.selected = 0
	await _on_format_list_item_selected(0)


func _on_format_list_item_selected(index: int) -> void:
	if not camera_feed:
		return

	var formats := camera_feed.get_formats()
	if index < 0 or index >= formats.size():
		return

	if camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
		await get_tree().create_timer(CAMERA_DEACTIVATION_DELAY).timeout

	var os_name := OS.get_name()
	var parameters: Dictionary = DEFAULT_WEB_RESOLUTION if os_name == "Web" else {}
	camera_feed.set_format(index, parameters)

	await get_tree().process_frame
	_start_camera_feed()


func _start_camera_feed() -> void:
	if not camera_feed:
		return

	_texture_initialized = false
	_last_feed_transform = Transform2D()

	if not camera_feed.frame_changed.is_connected(_on_frame_changed):
		camera_feed.frame_changed.connect(_on_frame_changed)

	camera_feed.feed_is_active = true


func _update_scene_transform() -> void:
	if not camera_feed or not camera_feed.feed_is_active:
		return
	if _cached_formats.is_empty():
		return

	var mat: ShaderMaterial = camera_preview.material
	if not mat:
		return

	var preview_size := _get_preview_size(mat)
	if preview_size.round().x <= 0 or preview_size.round().y <= 0:
		return

	var is_front_camera := camera_feed.get_position() == CameraFeed.FeedPosition.FEED_FRONT
	mirror_container.scale = Vector2(-1.0 if is_front_camera else 1.0, 1.0)

	rotation_container.rotation = camera_feed.feed_transform.get_rotation()

	var display_size := DisplayServer.window_get_size()
	if display_size.x > display_size.y:
		aspect_container.ratio = preview_size.x / preview_size.y
	else:
		aspect_container.ratio = preview_size.y / preview_size.x


func _get_preview_size(mat: ShaderMaterial) -> Vector2:
	var datatype := camera_feed.get_datatype() as CameraFeed.FeedDataType
	match datatype:
		CameraFeed.FeedDataType.FEED_RGB:
			var texture: CameraTexture = mat.get_shader_parameter(&"rgb_texture")
			if texture:
				return texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR_SEP:
			var texture: CameraTexture = mat.get_shader_parameter(&"y_texture")
			if texture:
				return texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR:
			var texture: CameraTexture = mat.get_shader_parameter(&"ycbcr_texture")
			if texture:
				return texture.get_size()
	return Vector2.ZERO


func _on_frame_changed() -> void:
	if not camera_feed or not camera_feed.feed_is_active:
		return
	if _cached_formats.is_empty():
		return

	if not _texture_initialized:
		_setup_textures()

	var current_transform := camera_feed.feed_transform
	if current_transform != _last_feed_transform:
		_last_feed_transform = current_transform
		_update_scene_transform()


func _setup_textures() -> void:
	var mat: ShaderMaterial = camera_preview.material
	var rgb_texture: CameraTexture = mat.get_shader_parameter(&"rgb_texture")
	var y_texture: CameraTexture = mat.get_shader_parameter(&"y_texture")
	var cbcr_texture: CameraTexture = mat.get_shader_parameter(&"cbcr_texture")
	var ycbcr_texture: CameraTexture = mat.get_shader_parameter(&"ycbcr_texture")

	rgb_texture.which_feed = CameraServer.FeedImage.FEED_RGBA_IMAGE
	y_texture.which_feed = CameraServer.FeedImage.FEED_Y_IMAGE
	cbcr_texture.which_feed = CameraServer.FeedImage.FEED_CBCR_IMAGE
	ycbcr_texture.which_feed = CameraServer.FEED_YCBCR_IMAGE

	var datatype := camera_feed.get_datatype() as CameraFeed.FeedDataType
	var preview_size := Vector2.ZERO

	match datatype:
		CameraFeed.FeedDataType.FEED_RGB:
			rgb_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter(&"rgb_texture", rgb_texture)
			mat.set_shader_parameter(&"mode", ShaderMode.RGB)
			preview_size = rgb_texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR_SEP:
			y_texture.camera_feed_id = camera_feed.get_id()
			cbcr_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter(&"y_texture", y_texture)
			mat.set_shader_parameter(&"cbcr_texture", cbcr_texture)
			mat.set_shader_parameter(&"mode", ShaderMode.YCBCR_SEP)
			preview_size = y_texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR:
			ycbcr_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter(&"ycbcr_texture", ycbcr_texture)
			mat.set_shader_parameter(&"mode", ShaderMode.YCBCR)
			preview_size = ycbcr_texture.get_size()
		_:
			print("Skip formats that are not supported.")
			return

	if preview_size.round().x <= 0 or preview_size.round().y <= 0:
		return

	var white_image := Image.create(int(preview_size.x), int(preview_size.y), false, Image.FORMAT_RGBA8)
	white_image.fill(Color.WHITE)
	camera_preview.texture = ImageTexture.create_from_image(white_image)

	_texture_initialized = true
	start_or_stop_button.text = "Stop"


func _on_start_or_stop_button_pressed(change_label := true) -> void:
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
		await get_tree().process_frame
		camera_preview.texture = null
		camera_preview.rotation = 0
		_texture_initialized = false
		if change_label:
			start_or_stop_button.text = "Start"
	else:
		_start_camera_feed()
		if change_label:
			start_or_stop_button.text = "Stop"


func _on_reload_button_pressed() -> void:
	_on_start_or_stop_button_pressed(false)
	_reload_camera_list()


func _notification(what: int) -> void:
	if not _initialized:
		return
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_WM_SIZE_CHANGED:
			_adjust_ui()


func _exit_tree() -> void:
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
