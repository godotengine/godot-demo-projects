extends Control

func _ready():
	for c in $Pictures.get_children():
		$Picture.add_item("PIC: " + c.get_name())
	for c in $Effects.get_children():
		$Effect.add_item("FX: " + c.get_name())


func _on_picture_item_selected(ID):
	for c in range($Pictures.get_child_count()):
		if ID == c:
			$Pictures.get_child(c).show()
		else:
			$Pictures.get_child(c).hide()


func _on_effect_item_selected(ID):
	for c in range($Effects.get_child_count()):
		if ID == c:
			$Effects.get_child(c).show()
		else:
			$Effects.get_child(c).hide()
