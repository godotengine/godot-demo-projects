extends Control

var mousepos

@onready var observer = $"../Observer"

func _ready():
	if not check_wm_api():
		set_physics_process(false)
		set_process_input(false)


func _physics_process(_delta):
	var modetext = "Mode:\n"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		modetext += "Fullscreen\n"
	else:
		modetext += "Windowed\n"
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED):
		modetext += "FixedSize\n"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		modetext += "Minimized\n"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		modetext += "Maximized\n"
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		modetext += "MouseGrab\n"
		$Label_MouseModeCaptured_KeyInfo.show()
	else:
		$Label_MouseModeCaptured_KeyInfo.hide()

	$Label_Mode.text = modetext
	$Label_Position.text = str("Position:\n", DisplayServer.window_get_position())
	$Label_Size.text = str("Size:\n", DisplayServer.window_get_size())
	$Label_MousePosition.text = str("Mouse Position:\n", mousepos)
	$Label_Screen_Count.text = str("Screen_Count:\n", DisplayServer.get_screen_count())
	$Label_Screen_Current.text = str("Screen:\n", DisplayServer.window_get_current_screen())
	$Label_Screen0_Resolution.text = str("Screen0 Resolution:\n", DisplayServer.screen_get_size())
	$Label_Screen0_Position.text = str("Screen0 Position:\n", DisplayServer.screen_get_position())
	$Label_Screen0_DPI.text = str("Screen0 DPI:\n", DisplayServer.screen_get_dpi())

	if DisplayServer.get_screen_count() > 1:
		$Button_Screen0.show()
		$Button_Screen1.show()
		$Label_Screen1_Resolution.show()
		$Label_Screen1_Position.show()
		$Label_Screen1_DPI.show()
		$Label_Screen1_Resolution.text = str("Screen1 Resolution:\n", DisplayServer.window_get_size(1))
		$Label_Screen1_Position.text = str("Screen1 Position:\n", DisplayServer.screen_get_position(1))
		$Label_Screen1_DPI.text = str("Screen1 DPI:\n", DisplayServer.screen_get_dpi(1))
	else:
		$Button_Screen0.hide()
		$Button_Screen1.hide()
		$Label_Screen1_Resolution.hide()
		$Label_Screen1_Position.hide()
		$Label_Screen1_DPI.hide()

	$Button_Fullscreen.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	$Button_FixedSize.set_pressed(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED))
	$Button_Minimized.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED)
	$Button_Maximized.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED)
	$Button_MouseModeVisible.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE)
	$Button_MouseModeHidden.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN)
	$Button_MouseModeCaptured.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mousepos = event.position

	if event is InputEventKey:
		if Input.is_action_pressed(&"mouse_mode_visible"):
			observer.state = observer.STATE_MENU
			_on_Button_MouseModeVisible_pressed()

		if Input.is_action_pressed(&"mouse_mode_hidden"):
			observer.state = observer.STATE_MENU
			_on_Button_MouseModeHidden_pressed()

		if Input.is_action_pressed(&"mouse_mode_captured"):
			_on_Button_MouseModeCaptured_pressed()


func check_wm_api():
	var s = ""
	if not OS.has_method("get_screen_count"):
		s += " - get_screen_count()\n"
	if not OS.has_method("get_current_screen"):
		s += " - get_current_screen()\n"
	if not OS.has_method("set_current_screen"):
		s += " - set_current_screen()\n"
	if not OS.has_method("get_screen_position"):
		s += " - get_screen_position()\n"
	if not OS.has_method("get_screen_size"):
		s += " - get_screen_size()\n"
	if not OS.has_method("get_window_position"):
		s += " - get_window_position()\n"
	if not OS.has_method("set_window_position"):
		s += " - set_window_position()\n"
	if not OS.has_method("get_window_size"):
		s += " - get_window_size()\n"
	if not OS.has_method("set_window_size"):
		s += " - set_window_size()\n"
	if not OS.has_method("set_window_fullscreen"):
		s += " - set_window_fullscreen()\n"
	if not OS.has_method("is_window_fullscreen"):
		s += " - is_window_fullscreen()\n"
	if not OS.has_method("set_window_resizable"):
		s += " - set_window_resizable()\n"
	if not OS.has_method("is_window_resizable"):
		s += " - is_window_resizable()\n"
	if not OS.has_method("set_window_minimized"):
		s += " - set_window_minimized()\n"
	if not OS.has_method("is_window_minimized"):
		s += " - is_window_minimized()\n"
	if not OS.has_method("set_window_maximized"):
		s += " - set_window_maximized()\n"
	if not OS.has_method("is_window_maximized"):
		s += " - is_window_maximized()\n"

	if s.length() == 0:
		return true
	else:
		$"ImplementationDialog/Text".text += s
		$ImplementationDialog.show()
		return false


func _on_Button_MoveTo_pressed():
	DisplayServer.window_set_position(Vector2(100, 100))


func _on_Button_Resize_pressed():
	DisplayServer.window_set_size(Vector2(1024, 768))


func _on_Button_Screen0_pressed():
	DisplayServer.window_set_current_screen(0)


func _on_Button_Screen1_pressed():
	DisplayServer.window_set_current_screen(1)


func _on_Button_Fullscreen_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_Button_FixedSize_pressed():
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)


func _on_Button_Minimized_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func _on_Button_Maximized_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_Button_MouseModeVisible_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Button_MouseModeHidden_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_Button_MouseModeCaptured_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	observer.state = observer.STATE_GRAB
