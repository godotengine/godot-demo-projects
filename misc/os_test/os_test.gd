extends Node

@onready var rtl = $HBoxContainer/Features
@onready var csharp_test = $CSharpTest


# Returns a human-readable string from a date and time, date, or time dictionary.
func datetime_to_string(date):
	if (
		date.has("year")
		and date.has("month")
		and date.has("day")
		and date.has("hour")
		and date.has("minute")
		and date.has("second")
	):
		# Date and time.
		return "{year}-{month}-{day} {hour}:{minute}:{second}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})
	elif date.has("year") and date.has("month") and date.has("day"):
		# Date only.
		return "{year}-{month}-{day}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
		})
	else:
		# Time only.
		return "{hour}:{minute}:{second}".format({
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})


func scan_midi_devices():
	OS.open_midi_inputs()
	var devices = ", ".join(OS.get_connected_midi_inputs())
	OS.close_midi_inputs()
	return devices


func add_header(header):
	rtl.append_text("\n[font_size=24][color=#6df]{header}[/color][/font_size]\n\n".format({
		header = header,
	}))


func add_line(key, value):
	rtl.append_text("[color=#adf]{key}:[/color] {value}\n".format({
		key = key,
		value = value if str(value) != "" else "[color=#fff8](empty)[/color]",
	}))


func _ready():
	add_header("Audio")
	add_line("Mix rate", "%d Hz" % AudioServer.get_mix_rate())
	add_line("Output latency", "%f ms" % (AudioServer.get_output_latency() * 1000))
	add_line("Output device list", ", ".join(AudioServer.get_output_device_list()))
	add_line("Capture device list", ", ".join(AudioServer.get_input_device_list()))

	add_header("Date")
	add_line("Date and time (local)", Time.get_datetime_string_from_system(false, true))
	add_line("Date and time (UTC)", Time.get_datetime_string_from_system(true, true))
	add_line("Date (local)", Time.get_date_string_from_system(false))
	add_line("Date (UTC)", Time.get_date_string_from_system(true))
	add_line("Time (local)", Time.get_time_string_from_system(false))
	add_line("Time (UTC)", Time.get_time_string_from_system(true))
	add_line("Timezone", Time.get_time_zone_from_system())
	add_line("UNIX time", Time.get_unix_time_from_system())

	add_header("Display")
	add_line("Screen count", DisplayServer.get_screen_count())
	add_line("DPI", DisplayServer.screen_get_dpi())
	add_line("Scale factor", DisplayServer.screen_get_scale())
	add_line("Maximum scale factor", DisplayServer.screen_get_max_scale())
	add_line("Startup screen position", DisplayServer.screen_get_position())
	add_line("Startup screen size", DisplayServer.screen_get_size())
	add_line("Startup screen refresh rate", ("%f Hz" % DisplayServer.screen_get_refresh_rate()) if DisplayServer.screen_get_refresh_rate() > 0.0 else "")
	add_line("Usable (safe) area rectangle", DisplayServer.get_display_safe_area())
	add_line("Screen orientation", [
		"Landscape",
		"Portrait",
		"Landscape (reverse)",
		"Portrait (reverse)",
		"Landscape (defined by sensor)",
		"Portrait (defined by sensor)",
		"Defined by sensor",
	][DisplayServer.screen_get_orientation()])

	add_header("Engine")
	add_line("Version", Engine.get_version_info()["string"])
	add_line("Command-line arguments", str(OS.get_cmdline_args()))
	add_line("Is debug build", OS.is_debug_build())
	add_line("Executable path", OS.get_executable_path())
	add_line("User data directory", OS.get_user_data_dir())
	add_line("Filesystem is persistent", OS.is_userfs_persistent())

	add_header("Environment")
	add_line("Value of `PATH`", OS.get_environment("PATH"))
	add_line("Value of `path`", OS.get_environment("path"))

	add_header("Hardware")
	add_line("Model name", OS.get_model_name())
	add_line("Processor name", OS.get_processor_name())
	add_line("Processor count", OS.get_processor_count())
	add_line("Device unique ID", OS.get_unique_id())

	add_header("Input")
	add_line("Device has touch screen", DisplayServer.is_touchscreen_available())
	var has_virtual_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	add_line("Device has virtual keyboard", has_virtual_keyboard)
	if has_virtual_keyboard:
		add_line("Virtual keyboard height", DisplayServer.virtual_keyboard_get_height())

	add_header("Localization")
	add_line("Locale", OS.get_locale())

	add_header("Mobile")
	add_line("Granted permissions", OS.get_granted_permissions())

	add_header(".NET (C#)")
	var csharp_enabled = ResourceLoader.exists("res://CSharpTest.cs")
	add_line("Mono module enabled", "Yes" if csharp_enabled else "No")
	if csharp_enabled:
		csharp_test.set_script(load("res://CSharpTest.cs"))
		add_line("Operating System", csharp_test.OperatingSystem())
		add_line("Platform Type", csharp_test.PlatformType())

	add_header("Software")
	add_line("OS name", OS.get_name())
	add_line("Process ID", OS.get_process_id())
	add_line("System dark mode supported", DisplayServer.is_dark_mode_supported())
	add_line("System dark mode enabled", DisplayServer.is_dark_mode())
	add_line("System accent color", "#%s" % DisplayServer.get_accent_color().to_html())

	add_header("System directories")
	add_line("Desktop", OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
	add_line("DCIM", OS.get_system_dir(OS.SYSTEM_DIR_DCIM))
	add_line("Documents", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	add_line("Downloads", OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	add_line("Movies", OS.get_system_dir(OS.SYSTEM_DIR_MOVIES))
	add_line("Music", OS.get_system_dir(OS.SYSTEM_DIR_MUSIC))
	add_line("Pictures", OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	add_line("Ringtones", OS.get_system_dir(OS.SYSTEM_DIR_RINGTONES))

	add_header("Video")
	add_line("Adapter name", RenderingServer.get_video_adapter_name())
	add_line("Adapter vendor", RenderingServer.get_video_adapter_vendor())
	add_line("Adapter type", [
		"Other (Unknown)",
		"Integrated",
		"Discrete",
		"Virtual",
		"CPU",
	][RenderingServer.get_video_adapter_type()])
	add_line("Adapter graphics API version", RenderingServer.get_video_adapter_api_version())

	var video_adapter_driver_info = OS.get_video_adapter_driver_info()
	if video_adapter_driver_info.size() > 0:
		add_line("Adapter driver name", video_adapter_driver_info[0])
	if video_adapter_driver_info.size() > 1:
		add_line("Adapter driver version", video_adapter_driver_info[1])
