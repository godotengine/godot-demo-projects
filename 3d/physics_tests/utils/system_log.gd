extends Node


enum LogType {
	LOG,
	ERROR,
}

signal entry_logged(message, type)


func print_log(message):
	print(message)
	emit_signal("entry_logged", message, LogType.LOG)


func print_error(message):
	push_error(message)
	printerr(message)
	emit_signal("entry_logged", message, LogType.ERROR)
