extends Node


enum LogType {
	LOG,
	ERROR,
}

signal entry_logged(message, type)


func print_log(message):
	print(message)
	entry_logged.emit(message, LogType.LOG)


func print_error(message):
	push_error(message)
	printerr(message)
	entry_logged.emit(message, LogType.ERROR)
