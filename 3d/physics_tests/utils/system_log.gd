extends Node


signal entry_logged(message, type)

enum LogType {
	LOG,
	ERROR,
}


func print_log(message):
	print(message)
	emit_signal("entry_logged", message, LogType.LOG)


func print_error(message):
	push_error(message)
	printerr(message)
	emit_signal("entry_logged", message, LogType.ERROR)
