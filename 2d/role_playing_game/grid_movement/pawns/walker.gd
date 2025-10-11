## A pawn that can animate and walk around the grid.
class_name Walker
extends Pawn

@export var combat_actor: PackedScene
@export var pose_anims: SpriteFrames

var lost: bool = false
var grid_size: float

@onready var grid : Grid = get_parent()
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree.get(&"parameters/playback")
@onready var walk_animation_time: float = $AnimationPlayer.get_animation(&"walk").length
@onready var pose := $Pivot/Slime


func _ready() -> void:
	pose.sprite_frames = pose_anims
	update_look_direction(Vector2.RIGHT)
	grid_size = grid.tile_set.tile_size.x


func update_look_direction(direction: Vector2) -> void:
	$Pivot/FacingDirection.rotation = direction.angle()


func move_to(target_position: Vector2) -> void:
	set_process(false)
	var move_direction := (target_position - position).normalized()
	pose.play(&"idle")
	animation_playback.start(&"walk")

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	var end: Vector2 = $Pivot.position + move_direction * grid_size
	tween.tween_property($Pivot, ^"position", end, walk_animation_time)

	await tween.finished
	$Pivot.position = Vector2.ZERO
	position = target_position
	animation_playback.start(&"idle")
	pose.play(&"idle")

	set_process(true)


func bump() -> void:
	set_process(false)
	pose.play(&"bump")
	animation_playback.start(&"bump")
	await $AnimationTree.animation_finished
	animation_playback.start(&"idle")
	pose.play(&"idle")
	set_process(true)
