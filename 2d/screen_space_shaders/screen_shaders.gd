extends Control

@onready var effect: OptionButton = $Effect
@onready var effects: Control = $Effects
@onready var picture: OptionButton = $Picture
@onready var pictures: Control = $Pictures

func _ready() -> void:
	for c in pictures.get_children():
		picture.add_item("PIC: " + String(c.get_name()))
	for c in effects.get_children():
		effect.add_item("FX: " + String(c.get_name()))


func _on_picture_item_selected(id: int) -> void:
	for c in pictures.get_child_count():
		if id == c:
			pictures.get_child(c).show()
		else:
			pictures.get_child(c).hide()


func _on_effect_item_selected(id: int) -> void:
	for c in effects.get_child_count():
		if id == c:
			effects.get_child(c).show()
		else:
			effects.get_child(c).hide()
