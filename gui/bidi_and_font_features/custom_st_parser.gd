extends LineEdit

func _structured_text_parser(_args: Variant, p_text: String) -> Array:
	var output: Array[Vector3i] = []
	var tags := p_text.split(":")
	var prev := 0
	var count := tags.size()
	output.clear()

	for i in count:
		var range1 := Vector3i(prev, prev + tags[i].length(), TextServer.DIRECTION_AUTO)
		var range2 := Vector3i(prev + tags[i].length(), prev + tags[i].length() + 1, TextServer.DIRECTION_AUTO)
		output.push_front(range1)
		output.push_front(range2)
		prev = prev + tags[i].length() + 1

	return output
