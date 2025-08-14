extends Control

func _ready() -> void:
	$LineEditName.grab_focus() # Accessible UI should always have keyboard focus, since it is a main way of interacting with UI.


func _on_button_set_pressed() -> void:
	$Panel/LabelRegion.text = $LineEditLiveReg.text # Set live region text.
