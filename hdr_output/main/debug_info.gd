extends Label

func _process(_delta: float) -> void:
	var window := get_window()
	
	var device := RenderingServer.get_rendering_device();
	
	var device_has_hdr: bool = false
	if device:		
		device_has_hdr = device.has_feature(RenderingDevice.SUPPORTS_HDR_OUTPUT)
	
	text = ""
	text += "Display Server supports HDR: %s\n" % DisplayServer.has_feature(DisplayServer.FEATURE_HDR_OUTPUT)
	text += "Rendering Device supports HDR: %s\n" % device_has_hdr
	text += "Window supports HDR: %s\n" % DisplayServer.window_is_hdr_output_supported(window.get_window_id())
	
	if not DisplayServer.has_feature(DisplayServer.FEATURE_HDR_OUTPUT):
		tooltip_text = "Display Server does not support\nHDR output. This usually means\nthat Godot does not support HDR\noutput on your current platform,\nbut other Display Server drivers may support HDR output.\n\n"
	elif not device_has_hdr:
		tooltip_text = "Rendering Device does not support\nHDR output. Try changing the\nRendering Device driver in your\nproject settings to a driver that supports\nHDR output, such as d3d12 for Windows\nand metal for macOS.\n\n"
	elif not DisplayServer.window_is_hdr_output_supported(window.get_window_id()):
		tooltip_text = "Window does not support HDR output.\nPlease ensure that your window is\npositioned on a screen that is currently\nin HDR mode."
	
