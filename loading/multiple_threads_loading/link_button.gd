extends LinkButton

func _on_LinkButton_button_up():
	# warning-ignore:return_value_discarded
	OS.shell_open("http://docs.godotengine.org/en/3.2/tutorials/io/background_loading.html#using-multiple-threads")
