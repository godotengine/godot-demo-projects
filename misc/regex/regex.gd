extends VBoxContainer

# Member variables
var regex = RegEx.new()

func update_expression(text):
	regex.compile(text)
	update_text()

func update_text():
	for child in $List.get_children():
		child.queue_free()
	if regex.is_valid():
		var matches = regex.search($Text.get_text())
		if matches != null:
			for result in matches.get_strings():
				var label = Label.new()
				label.text = result
				$List.add_child(label)

func _ready():
	$Text.set_text("They asked me \"What's going on \\\"in the manor\\\"?\"")
	update_expression($Expression.text)
