extends OptionButton

@onready var cube_animation: AnimationPlayer = $"../../AnimationPlayer"


func _on_option_button_item_selected(index: int) -> void:
	cube_animation.process_mode = index as ProcessMode
