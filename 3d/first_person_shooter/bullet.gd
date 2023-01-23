extends RayCast3D

# Damage dealt per bullet hit.
const DAMAGE = 10


func _physics_process(_delta):
	var distance := 0.0

	# The collision check must be performed in `_physics_process()`, not `_ready()` or `_process()`.
	# Otherwise, it may be performed before the RayCast has time to update its collisions.
	if is_colliding():
		# Bullet hit something (enemy or solid surface).
		$HitLocation.global_position = get_collision_point()
		$HitLocation/GPUParticles3D.emitting = true
		if get_collider() is Enemy:
			var enemy: Enemy = get_collider()
			enemy.health -= DAMAGE
		if get_collider() is Box:
			var box: Box = get_collider()
			# Push box away from the player's shot.
			box.apply_central_impulse(-transform.basis.z)
			# Apply small upwards motion to make the box slide more with horizontal shots.
			box.apply_central_impulse(Vector3.UP * 0.5)

		distance = global_position.distance_to($HitLocation.global_position)
	else:
		# Bullet missed.
		distance = abs(target_position.z)

	# Set up tracer round visual effect.
	# The tracer is faded over time using an autoplaying AnimationPlayer.
	$Tracer.scale.y = distance
	$Tracer.position.z -= distance * 0.5

	# We've hit or missed something, no need to keep checking.
	# However, keep the bullet present in the scene for wall decals and particle effects.
	enabled = false
	set_physics_process(false)


func _on_expire_timer_timeout():
	# Bullet is no longer needed as its sound and particles have fully played.
	queue_free()
