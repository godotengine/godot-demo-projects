extends RigidBody3D

const APPEARANCE_LIFE = 1.0
const MAX_LIFE = 100.0

var _life := 0.0
var _enabled := false


func _ready() -> void:
	$CollisionShape3D.disabled = true


func _physics_process(_delta: float) -> void:
	if not _enabled:
		$CollisionShape3D.disabled = false
		_enabled = true


	_life += 1

	var life_left := MAX_LIFE - _life

	var appearance_fract := minf(float (_life) / float (APPEARANCE_LIFE), 1.0)
	var fract := float(life_left) / float(MAX_LIFE)
	fract *= appearance_fract

	fract = maxf(fract, 0.0001)

	$Scaler.scale = Vector3.ONE * fract

	if _life >= MAX_LIFE:
		queue_free()
