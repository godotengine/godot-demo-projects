extends RigidBody3D

@export var scale_curve: Curve

var _enabled: bool = false


func _ready() -> void:
	$CollisionShape3D.disabled = true


func _physics_process(_delta: float) -> void:
	# Start with physics collision disabled until the first tick.
	# This prevents bullets from colliding with the player when first shot, while still
	# allowing them to be moved by the player when they're laying on the ground.
	if !_enabled:
		$CollisionShape3D.disabled = false
		_enabled = true

	# Apply the appearance scaling according to the scale curve.
	var time_left_ratio: float = 1.0 - $Timer.time_left / $Timer.wait_time
	var scale_sampled := scale_curve.sample_baked(time_left_ratio)
	$Scaler.scale = Vector3.ONE * scale_sampled


func _on_timer_timeout() -> void:
	queue_free()
