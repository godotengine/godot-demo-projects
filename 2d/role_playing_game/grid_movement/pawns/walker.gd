extends Pawn

@export var combat_actor: PackedScene
@export var pose_anims: SpriteFrames

var lost := false
var grid_size: float

@onready var parent := get_parent()
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var walk_animation_time: float = $AnimationPlayer.get_animation("walk").length
@onready var pose := $Pivot/Slime


func _ready() -> void:
	pose.sprite_frames = pose_anims
	update_look_direction(Vector2.RIGHT)
	grid_size = parent.tile_set.tile_size.x


func _process(_delta: float) -> void:
	var input_direction := get_input_direction()
	# We only move in integer increments.
	input_direction = input_direction.round()

	if input_direction.is_zero_approx():
		return

	update_look_direction(input_direction)

	var target_position: Vector2 = parent.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	elif active:
		bump()


func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func update_look_direction(direction: Vector2) -> void:
	$Pivot/Sprite2D.rotation = direction.angle()


func move_to(target_position: Vector2) -> void:
	set_process(false)
	var move_direction := (target_position - position).normalized()
	pose.play("idle")
	animation_playback.start("walk")

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	var end: Vector2 = $Pivot.position + move_direction * grid_size
	tween.tween_property($Pivot, "position", end, walk_animation_time)

	await tween.finished
	$Pivot.position = Vector2.ZERO
	position = target_position
	animation_playback.start("idle")
	pose.play("idle")

	set_process(true)


func bump() -> void:
	set_process(false)
	pose.play("bump")
	animation_playback.start("bump")
	await $AnimationTree.animation_finished
	animation_playback.start("idle")
	pose.play("idle")
	set_process(true)
