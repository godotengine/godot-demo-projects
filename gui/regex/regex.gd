extends VBoxContainer

var regex := RegEx.new()

func _ready() -> void:
	%Text.set_text("They asked me \"What's going on \\\"in the manor\\\"?\"")
	update_expression(%Expression.text)


func update_expression(text: String) -> void:
	regex.compile(text)
	update_text()


func update_text() -> void:
	for child in %List.get_children():
		child.queue_free()

	if regex.is_valid():
		$HBoxContainer.modulate = Color.WHITE
		var matches := regex.search_all(%Text.get_text())
		if matches.size() >= 1:
			# List all matches and their respective captures.
			var match_number := 0
			for regex_match in matches:
				match_number += 1
				# `match` is a reserved GDScript keyword.
				var match_label := Label.new()
				match_label.text = "RegEx match #%d:" % match_number
				match_label.modulate = Color(0.6, 0.9, 1.0)
				%List.add_child(match_label)

				var capture_number := 0
				for result in regex_match.get_strings():
					capture_number += 1
					var capture_label := Label.new()
					capture_label.text = "    Capture group #%d: %s" % [capture_number, result]
					%List.add_child(capture_label)
	else:
		$HBoxContainer.modulate = Color(1, 0.2, 0.1)
		var label := Label.new()
		label.text = "Error: Invalid regular expression. Check if the expression is correctly escaped and terminated."
		%List.add_child(label)


func _on_help_meta_clicked(_meta: Variant) -> void:
	# Workaround for clickable link doing nothing when clicked.
	OS.shell_open("https://regexr.com")
