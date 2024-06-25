extends Node2D


func _on_msaa_option_button_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA
