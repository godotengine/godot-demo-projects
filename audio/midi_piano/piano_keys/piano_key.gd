class_name PianoKey
extends Control

var pitch_scale: float

@onready var key: ColorRect = $Key
@onready var start_color: Color = key.color
@onready var color_timer: Timer = $ColorTimer

func setup(pitch_index: int) -> void:
	name = "PianoKey" + str(pitch_index)
	var exponent := (pitch_index - 69.0) / 12.0
	pitch_scale = pow(2, exponent)


func activate() -> void:
	key.color = (Color.YELLOW + start_color) / 2
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = preload("res://piano_keys/A440.wav")
	audio.pitch_scale = pitch_scale
	audio.play()
	color_timer.start()
	await get_tree().create_timer(8.0).timeout
	audio.queue_free()


func deactivate() -> void:
	key.color = start_color
