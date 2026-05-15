extends Panel

@onready var load_button: Button = $LoadButton
@onready var status_label: Label = $StatusLabel


func _ready() -> void:
	_update_status()


func _on_load_button_pressed() -> void:
	var slot: Node = $HeavySlot
	if not slot is InstancePlaceholder:
		return
	# Lazy-load: actually load `heavy_scene.tscn` and instantiate it now.
	# `replace = true` frees this InstancePlaceholder and inserts the new
	# node as a child of the same parent, preserving the slot's name and
	# position in the children list.
	(slot as InstancePlaceholder).create_instance(true)
	load_button.disabled = true
	_update_status()


func _update_status() -> void:
	var slot: Node = $HeavySlot
	if slot is InstancePlaceholder:
		status_label.text = "HeavySlot is currently an InstancePlaceholder. " \
				+ "Press the button to lazily load the real scene."
	else:
		status_label.text = "HeavySlot is now an instance of heavy_scene.tscn. " \
				+ "Its resources were not loaded until you pressed the button."
