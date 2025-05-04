extends BaseButton

@export var others: Array[BaseButton] = []

enum Behavior {
	ENABLE_OTHERS_WHEN_ENABLED,
	ENABLE_OTHERS_WHEN_DISABLED
}

@export var behavior: Behavior = Behavior.ENABLE_OTHERS_WHEN_ENABLED

func _ready() -> void:
	var others_disabled: bool
	if behavior == Behavior.ENABLE_OTHERS_WHEN_ENABLED:
		others_disabled = not button_pressed
	else:
		others_disabled = button_pressed
	for other in others:
		other.disabled = others_disabled


func _toggled(toggled_on: bool) -> void:
	if behavior == Behavior.ENABLE_OTHERS_WHEN_ENABLED:
		for other in others:
			other.disabled = not toggled_on
	else:
		for other in others:
			other.disabled = toggled_on
