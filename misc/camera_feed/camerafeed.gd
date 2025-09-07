extends Control

@onready var camera_display := $CameraDisplay
@onready var camera_preview := $CameraDisplay/CameraPreview
@onready var camera_list := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/CameraList
@onready var format_list := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/FormatList
@onready var start_or_stop_button := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/ButtonContainer/StartOrStopButton
@onready var reload_button := $DrawerContainer/Drawer/DrawerContent/VBoxContainer/ButtonContainer/ReloadButton

var camera_feed: CameraFeed
var _initialized: bool = false

const defaultWebResolution: Dictionary = {
	"width": 640,
	"height": 480,
}

func _ready() -> void:
	_adjust_ui()
	_reload_camera_list()
	_initialized = true


func _adjust_ui() -> void:
	camera_display.size = camera_display.get_parent_area_size() - Vector2.ONE * 40
	camera_preview.custom_minimum_size = camera_display.size
	camera_preview.position = camera_display.size / 2


func _reload_camera_list() -> void:
	camera_list.clear()
	format_list.clear()

	var os_name := OS.get_name()
	# Request camera permission on mobile.
	if os_name in ["Android", "iOS"]:
		var permissions = OS.get_granted_permissions()
		if not "CAMERA" in permissions:
			if not OS.request_permission("CAMERA"):
				print("CAMERA permission not granted")
				return

	if CameraServer.camera_feeds_updated.is_connected(_on_camera_feeds_updated):
		CameraServer.camera_feeds_updated.disconnect(_on_camera_feeds_updated)
	CameraServer.camera_feeds_updated.connect(_on_camera_feeds_updated, ConnectFlags.CONNECT_ONE_SHOT)

	if CameraServer.monitoring_feeds:
		CameraServer.monitoring_feeds = false
		await get_tree().process_frame

	CameraServer.monitoring_feeds = true


func _on_camera_feeds_updated() -> void:
	# Get available camera feeds.
	var feeds = CameraServer.feeds()
	if feeds.is_empty():
		camera_list.add_item("No cameras found")
		camera_list.disabled = true
		format_list.add_item("No formats available")
		format_list.disabled = true
		start_or_stop_button.disabled = true
		return

	camera_list.disabled = false
	for i in range(feeds.size()):
		var feed: CameraFeed = feeds[i]
		camera_list.add_item(feed.get_name())

	# Auto-select first camera.
	camera_list.selected = 0
	_on_camera_list_item_selected(0)


func _on_camera_list_item_selected(index: int) -> void:
	var camera_feeds := CameraServer.feeds()
	if index < 0 or index >= camera_feeds.size():
		return

	# Stop previous camera if active.
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false

	# Get selected camera feed.
	camera_feed = camera_feeds[index]

	# Update format list.
	_update_format_list()


func _update_format_list() -> void:
	format_list.clear()

	if not camera_feed:
		return

	var formats = camera_feed.get_formats()
	if formats.is_empty():
		format_list.add_item("No formats available")
		format_list.disabled = true
		start_or_stop_button.disabled = true
		return

	format_list.disabled = false
	start_or_stop_button.disabled = false
	for format in formats:
		var resolution := str(format["width"]) + "x" + str(format["height"])
		var item := "%s - %s" % [format["format"], resolution]
		if OS.get_name() == "Windows":
			item += " : %s / %s" % [format["frame_numerator"], format["frame_denominator"]]
		format_list.add_item(item)

	# Auto-select first format.
	format_list.selected = 0
	_on_format_list_item_selected(0)


func _on_format_list_item_selected(index: int) -> void:
	if not camera_feed:
		return

	var formats := camera_feed.get_formats()
	if index < 0 or index >= formats.size():
		return
	var os_name := OS.get_name()
	var parameters: Dictionary = defaultWebResolution if os_name == "Web" else {}
	camera_feed.set_format(index, parameters)
	_start_camera_feed()


func _start_camera_feed() -> void:
	if not camera_feed:
		return

	if not camera_feed.frame_changed.is_connected(_on_frame_changed):
		camera_feed.frame_changed.connect(_on_frame_changed, ConnectFlags.CONNECT_ONE_SHOT)
	# Start the feed.
	camera_feed.feed_is_active = true


func _on_frame_changed() -> void:
	var datatype := camera_feed.get_datatype() as CameraFeed.FeedDataType
	var preview_size := Vector2.ZERO

	var mat: ShaderMaterial = camera_preview.material
	var rgb_texture: CameraTexture = mat.get_shader_parameter("rgb_texture")
	var y_texture: CameraTexture = mat.get_shader_parameter("y_texture")
	var cbcr_texture: CameraTexture = mat.get_shader_parameter("cbcr_texture")
	var ycbcr_texture: CameraTexture = mat.get_shader_parameter("ycbcr_texture")

	rgb_texture.which_feed = CameraServer.FeedImage.FEED_RGBA_IMAGE
	y_texture.which_feed = CameraServer.FeedImage.FEED_Y_IMAGE
	cbcr_texture.which_feed = CameraServer.FeedImage.FEED_CBCR_IMAGE
	ycbcr_texture.which_feed = CameraServer.FEED_YCBCR_IMAGE

	match datatype:
		CameraFeed.FeedDataType.FEED_RGB:
			rgb_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter("rgb_texture", rgb_texture)
			mat.set_shader_parameter("mode", 0)
			preview_size = rgb_texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR_SEP:
			y_texture.camera_feed_id = camera_feed.get_id()
			cbcr_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter("y_texture", y_texture)
			mat.set_shader_parameter("cbcr_texture", cbcr_texture)
			mat.set_shader_parameter("mode", 1)
			preview_size = y_texture.get_size()
		CameraFeed.FeedDataType.FEED_YCBCR:
			ycbcr_texture.camera_feed_id = camera_feed.get_id()
			mat.set_shader_parameter("ycbcr_texture", ycbcr_texture)
			mat.set_shader_parameter("mode", 2)
			preview_size = ycbcr_texture.get_size()
		_:
			print("Skip formats that are not supported.")
			return

	var white_image := Image.create(int(preview_size.x), int(preview_size.y), false, Image.FORMAT_RGBA8)
	white_image.fill(Color.WHITE)
	camera_preview.texture = ImageTexture.create_from_image(white_image)

	var rot := camera_feed.feed_transform.get_rotation()
	var degree := roundi(rad_to_deg(rot))
	camera_preview.rotation = rot
	camera_preview.custom_minimum_size.y = camera_display.size.y

	if absi(degree) % 180 == 0:
		camera_display.ratio = preview_size.x / preview_size.y
	else:
		camera_display.ratio = preview_size.y / preview_size.x

	start_or_stop_button.text = "Stop"


func _on_start_or_stop_button_pressed(change_label: bool = true) -> void:
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
		camera_preview.texture = null
		camera_preview.rotation = 0
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
	if what == NOTIFICATION_RESIZED and _initialized:
		_adjust_ui()


func _exit_tree() -> void:
	if camera_feed and camera_feed.feed_is_active:
		camera_feed.feed_is_active = false
