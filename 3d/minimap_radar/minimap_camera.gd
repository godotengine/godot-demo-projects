extends Camera


# enemies that are lower or above player position + offset will be clipped from minimap few
export(float) var minimap_viewsize = 30.0 setget _set_minimap_viewsize, _get_minimap_viewsize
export(float) var camera_up_clip_distance = 10.0 setget _set_up_clip_distance, _get_up_clip_distance
export(float) var camera_down_clip_distance = 10.0 setget _set_down_clip_distance, _get_down_clip_distance


func _ready() -> void:
	size = minimap_viewsize
	translation.y = camera_up_clip_distance
	far = camera_down_clip_distance + camera_up_clip_distance + 1.0 # clipmargin


func _set_down_clip_distance(value) -> void:
	camera_down_clip_distance = value
	far = camera_down_clip_distance + camera_up_clip_distance + 1.0 # clipmargin


func _get_down_clip_distance() -> float:
	return camera_down_clip_distance


func _set_up_clip_distance(value) -> void:
	camera_up_clip_distance = value


func _get_up_clip_distance() -> float:
	return camera_up_clip_distance


func _set_minimap_viewsize(value) -> void:
	minimap_viewsize = value
	size = minimap_viewsize


func _get_minimap_viewsize() -> float:
	return minimap_viewsize
