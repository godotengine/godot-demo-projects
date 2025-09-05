extends Control

var message_counter := 0
var message_raw_counter := 0
var message_stderr_counter := 0
var warning_counter := 0
var error_counter := 0


func _ready() -> void:
	print("Normal message 1.")
	push_error("Error 1.")
	push_warning("Warning 1.")
	push_error("Error 2.")
	push_warning("Warning 2.")
	print("Normal message 2.")
	printerr("Normal message 1 (stderr).")
	printerr("Normal message 2 (stderr).")
	printraw("Normal message 1 (raw). ")
	printraw("Normal message 2 (raw).\n--------\n")

	if bool(ProjectSettings.get_setting_with_override("application/run/flush_stdout_on_print")):
		$FlushStdoutOnPrint.text = "Flush stdout on print: Yes (?)"
	else:
		$FlushStdoutOnPrint.text = "Flush stdout on print: No (?)"


func _on_print_message_pressed() -> void:
	message_counter += 1
	print("Printing message #%d." % message_counter)


func _on_print_message_raw_pressed() -> void:
	message_raw_counter += 1
	printraw("Printing message #%d (raw). " % message_raw_counter)


func _on_print_message_stderr_pressed() -> void:
	message_stderr_counter += 1
	printerr("Printing message #%d (stderr)." % message_stderr_counter)


func _on_print_warning_pressed() -> void:
	warning_counter += 1
	push_warning("Printing warning #%d." % warning_counter)


func _on_print_error_pressed() -> void:
	error_counter += 1
	push_error("Printing error #%d." % error_counter)


func _on_open_logs_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(String(ProjectSettings.get_setting_with_override("debug/file_logging/log_path")).get_base_dir()))


func _on_crash_engine_pressed() -> void:
	OS.crash("Crashing the engine on user request (the Crash Engine button was pressed). Do not report this as a bug.")
