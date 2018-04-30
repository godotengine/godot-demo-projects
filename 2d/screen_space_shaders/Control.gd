extends Control

func _ready():
	for c in  $effects.get_children():
		$effect.add_item("FX: " + c.get_name())

func _on_effect_item_selected(ID):
	for c in range($effects.get_child_count()):
		if ID == c:
			$effects.get_child(c).show()
		else:
			$effects.get_child(c).hide()
