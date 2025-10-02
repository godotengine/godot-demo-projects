extends Node

enum LogType {
	LOG,
	ERROR,
}

signal entry_logged(message: String, type: LogType)

func print_log(message: String) -> void:
	print(message)
	entry_logged.emit(message, LogType.LOG)


func print_error(message: String) -> void:
	push_error(message)
	printerr(message)
	entry_logged.emit(message, LogType.ERROR)
