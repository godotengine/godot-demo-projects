class_name MovingPlatform
extends Node2D

export var motion = Vector2()
export var cycle = 1.0

var accum = 0.0

func _physics_process(delta):
	accum += delta * (1.0 / cycle) * TAU
	accum = fmod(accum, TAU)

	var d = sin(accum)
	var xf = Transform2D()

	xf[2]= motion * d
	($Platform as RigidBody2D).transform = xf
