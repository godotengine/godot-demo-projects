extends Label

var _unpaused_frame_count : int = 0


func reset() -> void:
	_unpaused_frame_count = 0
	text = "%d Frames" % [_unpaused_frame_count]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(_delta: float) -> void:
	text = "%d Frames" % [_unpaused_frame_count]


func _physics_process(_delta: float) -> void:
	_unpaused_frame_count += 1
