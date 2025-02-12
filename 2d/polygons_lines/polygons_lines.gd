extends Node2D


func _ready() -> void:
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility":
		$MSAA.visible = false
		$UnsupportedLabel.visible = true


func _on_msaa_option_button_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA
