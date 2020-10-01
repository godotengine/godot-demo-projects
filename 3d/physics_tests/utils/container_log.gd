extends Control


const MAX_ENTRIES = 100

var _entry_template


func _enter_tree():
	Log.connect("entry_logged", self, "_on_log_entry")

	_entry_template = get_child(0) as Label
	remove_child(_entry_template)


func clear():
	while get_child_count():
		var entry = get_child(get_child_count() - 1)
		remove_child(entry)
		entry.queue_free()


func _on_log_entry(message, type):
	var new_entry = _entry_template.duplicate() as Label

	new_entry.set_text(message)
	if type == Log.LogType.ERROR:
		new_entry.modulate = Color.red
	else:
		new_entry.modulate = Color.white

	if get_child_count() >= MAX_ENTRIES:
		var first_entry = get_child(0) as Label
		remove_child(first_entry)
		first_entry.queue_free()

	add_child(new_entry)
