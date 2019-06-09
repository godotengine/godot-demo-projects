extends RigidBody2D

class_name Enemy

# Member variables
const WALK_SPEED = 50
const STATE_WALKING = 0
const STATE_DYING = 1

# state machine
var state = STATE_WALKING

var direction = -1
var anim = ""

onready var rc_left = $RaycastLeft
onready var rc_right = $RaycastRight

var Bullet = preload("res://player/bullet.gd")


func _die():
	queue_free()

func _pre_explode():
	#make sure nothing collides against this
	$Shape1.queue_free()
	$Shape2.queue_free()
	$Shape3.queue_free()
	
	# Stay there
	mode = MODE_STATIC
	($SoundExplode as AudioStreamPlayer2D).play()
	
func _bullet_collider(cc, s, dp):
	mode = MODE_RIGID
	state = STATE_DYING
	
	s.set_angular_velocity(sign(dp.x) * 33.0)
	set_friction(1)
	cc.disable()
	($SoundHit as AudioStreamPlayer2D).play()

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var new_anim = anim

	if state == STATE_DYING:
		new_anim = "explode"
	elif state == STATE_WALKING:
		new_anim = "walk"
		
		var wall_side = 0.0
		
		for i in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(i)
			var dp = s.get_contact_local_normal(i)
			
			if cc:
				if cc is Bullet and not cc.disabled:
					# enqueue call
					call_deferred("_bullet_collider", cc, s, dp)
					break
			
			if dp.x > 0.9:
				wall_side = 1.0
			elif dp.x < -0.9:
				wall_side = -1.0
		
		if wall_side != 0 and wall_side != direction:
			direction = -direction
			($Sprite as Sprite).scale.x = -direction
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = -direction
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = -direction
		
		lv.x = direction * WALK_SPEED
	
	if anim != new_anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)
	
	s.set_linear_velocity(lv)
