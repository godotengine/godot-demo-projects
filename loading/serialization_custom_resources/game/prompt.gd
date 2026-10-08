extends Label
class_name Prompt


func show_whose_it(it_name : String) -> void:
	match it_name:
		"you":
			text = "Tag, you are it!"
		_:
			text = "Tag, {0} is it!".format([it_name])
