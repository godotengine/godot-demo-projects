extends RayCast3D

# Damage dealt per bullet hit.
const DAMAGE = 9


func _physics_process(_delta: float) -> void:
	var distance := 0.0

	# The collision check must be performed in `_physics_process()`, not `_ready()` or `_process()`.
	# Otherwise, it may be performed before the RayCast has time to update its collisions.
	if is_colliding():
		# Bullet hit something (enemy or solid surface).
		$HitLocation.global_position = get_collision_point()
		$HitLocation/GPUParticles3D.emitting = true

		if get_collider() is Enemy:
			var enemy := get_collider() as Enemy
			enemy.damage(DAMAGE)

		if get_collider() is Player:
			var player := get_collider() as Player
			player.health -= DAMAGE
			# Push player away from the bullet's direction.
			player.velocity -= transform.basis.z * 1.5

		if get_collider() is Box:
			var box := get_collider() as Box
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


func _on_expire_timer_timeout() -> void:
	# Bullet is no longer needed as its sound and particles have fully played.
	queue_free()
