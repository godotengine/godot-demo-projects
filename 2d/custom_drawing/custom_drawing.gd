extends Control


func _on_msaa_2d_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA


func _on_draw_antialiasing_toggled(toggled_on: bool) -> void:
	var nodes: Array[Node] = %TabContainer.get_children()
	nodes.push_back(%AnimationSlice)
	for tab: Control in nodes:
		tab.use_antialiasing = toggled_on
		# Force all tabs to redraw so that the antialiasing updates.
		tab.queue_redraw()
