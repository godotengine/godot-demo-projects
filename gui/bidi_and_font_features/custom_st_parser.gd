extends LineEdit

func _structured_text_parser(args, text):
	var output = []
	var tags = text.split(":")
	var prev = 0
	var count = int(tags.size())
	output.clear()
	for i in range(count):
		var range1 = Vector2i(prev, prev + tags[i].length())
		var range2 = Vector2i(prev + tags[i].length(), prev + tags[i].length() + 1)
		output.push_front(range1)
		output.push_front(range2)
		prev = prev + tags[i].length() + 1
	return output
