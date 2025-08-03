extends Sprite2D

var _guide_tween: Tween


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("main_key"):
		scale = 1.2 * Vector2.ONE
		if _guide_tween:
			_guide_tween.kill()
		_guide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_guide_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
