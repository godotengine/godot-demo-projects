extends RayCast3D

# Damage dealt per bullet hit.
const DAMAGE = 10


func _physics_process(_delta):
	# The collision check must be performed in `_physics_process()`, not `_ready()` or `_process()`.
	# Otherwise, it may be performed before the RayCast has time to update its collisions.
	if is_colliding():
		$HitLocation.global_position = get_collision_point()
		$HitLocation/GPUParticles3D.emitting = true
		if get_collider() is Enemy:
			var enemy: Enemy = get_collider()
			enemy.health -= DAMAGE

		# We've hit something, no need to keep checking.
		# However, keep the bullet present in the scene for wall decals and particle effects.
		set_physics_process(false)
	else:
		queue_free()
