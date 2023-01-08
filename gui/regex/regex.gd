extends VBoxContainer

var regex = RegEx.new()

func _ready():
	%Text.text = "The file is located in /tmp/test/index.html, and not in /x/y/z.html."
	%Expression.text = "(/.+?\\.html).+?(/.+?\\.html)"
	update_expression(%Expression.text)


func update_expression(text):
	regex.compile(text)
	update_text()


func update_text():
	for child in %List.get_children():
		child.queue_free()
	if not regex.is_valid():
		return
	var matches = regex.search_all(%Text.text)
	if matches == null:
		return
	for i in matches.size():
		var result = matches[i]
		for j in result.strings.size():
			var pattern = result.strings[j]
			if pattern == "":
				continue
			var label = Label.new()
			var match_text = "Match %d" % [i + 1] if j == 0 else "    Group %d" % [j]
			label.text = "%s: %s" % [match_text, pattern]
			%List.add_child(label)
