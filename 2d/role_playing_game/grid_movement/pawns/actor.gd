extends Pawn

var lost = false
@onready var Grid = get_parent()


func _ready():
	update_look_direction(Vector2.RIGHT)


func _process(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	else:
		bump()


func get_input_direction():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)


func update_look_direction(direction):
	$Pivot/Sprite2D.rotation = direction.angle()


func move_to(target_position):
	set_process(false)
	$AnimationPlayer.play("walk")
	var move_direction = (position - target_position).normalized()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Pivot, "position", $Pivot.position + move_direction * 32, $AnimationPlayer.current_animation_length)
	$Pivot/Sprite2D.position = position - target_position
	position = target_position

	await $AnimationPlayer.animation_finished

	set_process(true)


func bump():
	$AnimationPlayer.play("bump")
