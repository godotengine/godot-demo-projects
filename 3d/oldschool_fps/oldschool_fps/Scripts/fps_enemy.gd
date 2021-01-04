class_name FPSEnemy
extends RigidBody
# for this examples enemies simply move in a random direction until they die, then they are cycled out


const MIN_SPEED_BEFORE_CHANGING_DIR = 0.001
const ENEMY_SPEED_RANGE = 1000

export(float) var recovery_time = 0.2
export(float) var max_hp = 40
export(float) var decel_multiplier = 0.8
export(Color) var hit_colour = Color(1,0,0,1)

var base_colour
var hp = max_hp
var velocity = Vector3()
var active = false

var recovery_timer
var enemy_sprite
var enemy_manager


# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = get_node("Sprite3D")
	recovery_timer = get_node("RecoveryTimer")
	enemy_manager = get_node("../..")

	base_colour = enemy_sprite.modulate


func _physics_process(delta):
	if active:
		if velocity.length() < MIN_SPEED_BEFORE_CHANGING_DIR:
			velocity = Vector3(rand_range(-ENEMY_SPEED_RANGE,ENEMY_SPEED_RANGE),
					 0, rand_range(-ENEMY_SPEED_RANGE,ENEMY_SPEED_RANGE))

		velocity *= decel_multiplier
		apply_central_impulse(velocity * delta)


func take_damage(var damage, var direction, var knockback):
	# take the damage
	hp -= damage
	# react to the damage
	enemy_sprite.modulate = hit_colour
	velocity += -direction.normalized() * knockback

	if hp <= 0:
		die()
		return

	recovery_timer.start(recovery_time)


# pooling deactivation
func die():
	set_translation(enemy_manager.DEFAULT_ENEMY_SPAWN_POINT)
	active = false
	hp = max_hp
	enemy_manager.handle_death()


func _on_RecoveryTimer_timeout():
	enemy_sprite.modulate = base_colour
