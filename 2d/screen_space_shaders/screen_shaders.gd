extends Control

onready var effect = $Effect
onready var effects = $Effects
onready var picture = $Picture
onready var pictures = $Pictures


func _ready():
	for c in pictures.get_children():
		picture.add_item("PIC: " + c.get_name())
	for c in effects.get_children():
		effect.add_item("FX: " + c.get_name())


func _on_picture_item_selected(ID):
	for c in range(pictures.get_child_count()):
		if ID == c:
			pictures.get_child(c).show()
		else:
			pictures.get_child(c).hide()


func _on_effect_item_selected(ID):
	for c in range(effects.get_child_count()):
		if ID == c:
			effects.get_child(c).show()
		else:
			effects.get_child(c).hide()
