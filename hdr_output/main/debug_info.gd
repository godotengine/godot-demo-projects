extends Label

func _process(_delta: float) -> void:
	var window := get_window()
	
	var device := RenderingServer.get_rendering_device();
	
	var device_has_hdr: bool
	
	if device:		
		device_has_hdr = device.has_feature(RenderingDevice.SUPPORTS_HDR_OUTPUT)
	
	text = ""
	text += "DisplayServer Supports HDR: %s\n" % DisplayServer.has_feature(DisplayServer.FEATURE_HDR_OUTPUT)
	text += "RenderingDevice Supports HDR: %s\n" % device_has_hdr
	text += "Window Supports HDR: %s\n" % DisplayServer.window_is_hdr_output_supported(window.get_window_id())
	
