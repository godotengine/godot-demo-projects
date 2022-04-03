extends OptionButton

@onready var cube_animation = $"../../AnimationPlayer"


func _on_option_button_item_selected(index):
	cube_animation.process_mode = index
