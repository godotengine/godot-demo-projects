extends Control

var mouse_position := Vector2()

@onready var observer: CharacterBody3D = $"../Observer"

func _ready() -> void:
	if not check_wm_api():
		set_physics_process(false)
		set_process_input(false)

	# See godotengine/godot#73563, fetching the refresh rate on every frame may be slow on some platforms.
	$Labels/Label_Screen0_RefreshRate.text = "Screen0 Refresh Rate: %.2f Hz" % DisplayServer.screen_get_refresh_rate()
	if DisplayServer.get_screen_count() > 1:
		$Labels/Label_Screen1_RefreshRate.text = "Screen1 Refresh Rate: %.2f Hz" % DisplayServer.screen_get_refresh_rate(1)

func _physics_process(_delta: float) -> void:
	var modetext := "Mode: "
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		modetext += "Fullscreen\n"
	else:
		modetext += "Windowed\n"
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED):
		modetext += "Fixed Size\n"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		modetext += "Minimized\n"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		modetext += "Maximized\n"
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		modetext += "Mouse Captured\n"
		$Buttons/Label_MouseModeCaptured_KeyInfo.show()
	else:
		$Buttons/Label_MouseModeCaptured_KeyInfo.hide()

	$Labels/Label_Mode.text = modetext
	$Labels/Label_Position.text = str("Position: ", DisplayServer.window_get_position())
	$Labels/Label_Size.text = str("Size: ", DisplayServer.window_get_size())
	$Labels/Label_MousePosition.text = str("Mouse Position: ", mouse_position)
	$Labels/Label_Screen_Count.text = str("Screen_Count: ", DisplayServer.get_screen_count())
	$Labels/Label_Screen_Current.text = str("Screen: ", DisplayServer.window_get_current_screen())
	$Labels/Label_Screen0_Resolution.text = str("Screen0 Resolution:\n", DisplayServer.screen_get_size())
	$Labels/Label_Screen0_Position.text = str("Screen0 Position:\n", DisplayServer.screen_get_position())
	$Labels/Label_Screen0_DPI.text = str("Screen0 DPI: ", DisplayServer.screen_get_dpi())

	if DisplayServer.get_screen_count() > 1:
		$Buttons/Button_Screen0.show()
		$Buttons/Button_Screen1.show()
		$Labels/Label_Screen1_Resolution.show()
		$Labels/Label_Screen1_Position.show()
		$Labels/Label_Screen1_DPI.show()
		$Labels/Label_Screen1_Resolution.text = str("Screen1 Resolution:\n", DisplayServer.screen_get_size(1))
		$Labels/Label_Screen1_Position.text = str("Screen1 Position:\n", DisplayServer.screen_get_position(1))
		$Labels/Label_Screen1_DPI.text = str("Screen1 DPI: ", DisplayServer.screen_get_dpi(1))
	else:
		$Buttons/Button_Screen0.hide()
		$Buttons/Button_Screen1.hide()
		$Labels/Label_Screen1_Resolution.hide()
		$Labels/Label_Screen1_Position.hide()
		$Labels/Label_Screen1_DPI.hide()
		$Labels/Label_Screen1_RefreshRate.hide()

	$Buttons/Button_Fullscreen.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	$Buttons/Button_FixedSize.set_pressed(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED))
	$Buttons/Button_Minimized.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED)
	$Buttons/Button_Maximized.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED)
	$Buttons/Button_MouseModeVisible.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE)
	$Buttons/Button_MouseModeHidden.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN)
	$Buttons/Button_MouseModeCaptured.set_pressed(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position

	if event is InputEventKey:
		if Input.is_action_pressed(&"mouse_mode_visible"):
			observer.state = observer.State.MENU
			_on_button_mouse_mode_visible_pressed()

		if Input.is_action_pressed(&"mouse_mode_hidden"):
			observer.state = observer.State.MENU
			_on_button_mouse_mode_hidden_pressed()

		if Input.is_action_pressed(&"mouse_mode_captured"):
			_on_button_mouse_mode_captured_pressed()

		if Input.is_action_pressed(&"mouse_mode_confined"):
			observer.state = observer.State.MENU
			_on_button_mouse_mode_confined_pressed()

		if Input.is_action_pressed(&"mouse_mode_confined_hidden"):
			observer.state = observer.State.MENU
			_on_button_mouse_mode_confined_hidden_pressed()


func check_wm_api() -> bool:
	var s := ""
	if not DisplayServer.has_method("get_screen_count"):
		s += " - get_screen_count()\n"
	if not DisplayServer.has_method("window_get_current_screen"):
		s += " - window_get_current_screen()\n"
	if not DisplayServer.has_method("window_set_current_screen"):
		s += " - window_set_current_screen()\n"
	if not DisplayServer.has_method("screen_get_position"):
		s += " - screen_get_position()\n"
	if not DisplayServer.has_method("window_get_size"):
		s += " - window_get_size()\n"
	if not DisplayServer.has_method("window_get_position"):
		s += " - window_get_position()\n"
	if not DisplayServer.has_method("window_set_position"):
		s += " - window_set_position()\n"
	if not DisplayServer.has_method("window_get_size"):
		s += " - get_window_size()\n"
	if not DisplayServer.has_method("window_set_size"):
		s += " - window_set_size()\n"
# These function are no longer and this is set through flags!
#	if not DisplayServer.has_method("set_window_fullscreen"):
#		s += " - set_window_fullscreen()\n"
#	if not DisplayServer.window_get_flag() OS.has_method("is_window_fullscreen"):
#		s += " - is_window_fullscreen()\n"
#	if not OS.has_method("set_window_resizable"):
#		s += " - set_window_resizable()\n"
#	if not OS.has_method("is_window_resizable"):
#		s += " - is_window_resizable()\n"
#	if not OS.has_method("set_window_minimized"):
#		s += " - set_window_minimized()\n"
#	if not OS.has_method("is_window_minimized"):
#		s += " - is_window_minimized()\n"
#	if not OS.has_method("set_window_maximized"):
#		s += " - set_window_maximized()\n"
#	if not OS.has_method("is_window_maximized"):
#		s += " - is_window_maximized()\n"

	if s.length() == 0:
		return true
	else:
		$"ImplementationDialog/Text".text += s
		$ImplementationDialog.show()
		return false


func _on_button_move_to_pressed() -> void:
	DisplayServer.window_set_position(Vector2(100, 100))


func _on_button_resize_pressed() -> void:
	DisplayServer.window_set_size(Vector2(1280, 720))


func _on_button_screen_0_pressed() -> void:
	DisplayServer.window_set_current_screen(0)


func _on_button_screen_1_pressed() -> void:
	DisplayServer.window_set_current_screen(1)


func _on_button_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_button_fixed_size_pressed() -> void:
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)


func _on_button_minimized_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func _on_button_maximized_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_button_mouse_mode_visible_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_button_mouse_mode_hidden_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_button_mouse_mode_captured_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	observer.state = observer.State.GRAB

func _on_button_mouse_mode_confined_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _on_button_mouse_mode_confined_hidden_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
