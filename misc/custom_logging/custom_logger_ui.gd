extends RichTextLabel


class CustomLogger extends Logger:
	func _log_message(message: String, _error: bool) -> void:
		CustomLoggerUI.get_node("Panel/RichTextLabel").text += message


	func _log_error(
			function: String,
			file: String,
			line: int,
			code: String,
			rationale: String,
			_editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]
	) -> void:
		var prefix := ""
		# The column at which to print the trace. Should match the length of the
		# unformatted text above it.
		var trace_indent := 0

		match error_type:
			ERROR_TYPE_ERROR:
				prefix = "[color=#f54][b]ERROR:[/b]"
				trace_indent = 6
			ERROR_TYPE_WARNING:
				prefix = "[color=#fd4][b]WARNING:[/b]"
				trace_indent = 8
			ERROR_TYPE_SCRIPT:
				prefix = "[color=#f4f][b]SCRIPT ERROR:[/b]"
				trace_indent = 13
			ERROR_TYPE_SHADER:
				prefix = "[color=#4bf][b]SHADER ERROR:[/b]"
				trace_indent = 13

		var trace := "%*s %s (%s:%s)" % [trace_indent, "at:", function, file, line]
		var script_backtraces_text := ""
		for backtrace in script_backtraces:
			script_backtraces_text += backtrace.format(trace_indent - 3) + "\n"

		CustomLoggerUI.get_node("Panel/RichTextLabel").text += "%s %s %s[/color]\n[color=#999]%s[/color]\n[color=#999]%s[/color]" % [
				prefix,
				code,
				rationale,
				trace,
				script_backtraces_text,
			]


# Use `_init()` to initialize the logger as early as possible, which ensures that messages
# printed early are taken into account. However, even when using `_init()`, the engine's own
# initialization messages are not accessible.
func _init() -> void:
	OS.add_logger(CustomLogger.new())
