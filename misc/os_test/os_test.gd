extends Node

onready var rtl = $HBoxContainer/Features
onready var mono_test = $MonoTest


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


func add_header(header):
	rtl.append_bbcode("\n[b][u][color=#6df]{header}[/color][/u][/b]\n".format({
		header = header,
	}))


func add_line(key, value):
	rtl.append_bbcode("[b]{key}:[/b] {value}\n".format({
		key = key,
		value = value if str(value) != "" else "[color=#8fff](empty)[/color]",
	}))


func _ready():
	add_header("Audio")
	var audio_drivers = PoolStringArray()
	for i in OS.get_audio_driver_count():
		audio_drivers.push_back(OS.get_audio_driver_name(i))
	add_line("Available drivers", audio_drivers.join(", "))
	add_line("MIDI inputs", OS.get_connected_midi_inputs().join(", "))

	add_header("Date")
	add_line("Date and time (local)", datetime_to_string(OS.get_datetime()))
	add_line("Date and time (UTC)", datetime_to_string(OS.get_datetime(true)))
	add_line("Date (local)", datetime_to_string(OS.get_date()))
	add_line("Date (UTC)", datetime_to_string(OS.get_date(true)))
	add_line("Time (local)", datetime_to_string(OS.get_time()))
	add_line("Time (UTC)", datetime_to_string(OS.get_time(true)))
	add_line("Timezone", OS.get_time_zone_info())
	add_line("System time (milliseconds)", OS.get_system_time_msecs())
	add_line("System time (seconds)", OS.get_system_time_secs())
	add_line("UNIX time", OS.get_unix_time())

	add_header("Display")
	add_line("Screen count", OS.get_screen_count())
	add_line("DPI", OS.get_screen_dpi())
	add_line("Startup screen position", OS.get_screen_position())
	add_line("Startup screen size", OS.get_screen_size())
	add_line("Safe area rectangle", OS.get_window_safe_area())
	add_line("Screen orientation", [
		"Landscape",
		"Portrait",
		"Landscape (reverse)",
		"Portrait (reverse)",
		"Landscape (defined by sensor)",
		"Portrait (defined by sensor)",
		"Defined by sensor",
	][OS.screen_orientation])

	add_header("Engine")
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
	add_line("Processor count", OS.get_processor_count())
	add_line("Device unique ID", OS.get_unique_id())
	add_line("Video adapter name", VisualServer.get_video_adapter_name())
	add_line("Video adapter vendor", VisualServer.get_video_adapter_vendor())

	add_header("Input")
	add_line("Latin keyboard variant", OS.get_latin_keyboard_variant())
	add_line("Device has touch screen", OS.has_touchscreen_ui_hint())
	add_line("Device has virtual keyboard", OS.has_virtual_keyboard())
	add_line("Virtual keyboard height", OS.get_virtual_keyboard_height())

	add_header("Localization")
	add_line("Locale", OS.get_locale())

	add_header("Mobile")
	add_line("Granted permissions", OS.get_granted_permissions())

	add_header("Mono (C#)")
	var mono_enabled = ResourceLoader.exists("res://MonoTest.cs")
	add_line("Mono module enabled", "Yes" if mono_enabled else "No")
	if mono_enabled:
		mono_test.set_script(load("res://MonoTest.cs"))
		add_line("Operating System", mono_test.OperatingSystem())
		add_line("Platform Type", mono_test.PlatformType())

	add_header("Software")
	add_line("OS name", OS.get_name())
	add_line("Process ID", OS.get_process_id())

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
	var video_drivers = PoolStringArray()
	for i in OS.get_video_driver_count():
		video_drivers.push_back(OS.get_video_driver_name(i))
	add_line("Available drivers", video_drivers.join(", "))
	add_line("Current driver", OS.get_video_driver_name(OS.get_current_video_driver()))
