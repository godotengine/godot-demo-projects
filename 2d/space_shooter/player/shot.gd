extends Area2D

# Member variables
const SPEED = 800

var hit = false
var motion = Vector2()

func _process(delta):
	translate(motion * delta)

func _ready():
	motion = Vector2(SPEED, 0)
	set_process(true)

func _hit_something():
	if (hit):
		return
	hit = true
	set_process(false)
	get_node("anim").play("splash")
	# disable collisions
	call_deferred("set_enable_monitoring", false)
	call_deferred("set_monitorable", false)

func _on_visibility_exit_screen():
	queue_free()

func _on_shot_area_enter(area):
	# Hit an enemy or asteroid
	if (area.has_method("destroy")):
		# Duck typing at its best
		area.destroy()
		_hit_something()

func _on_shot_body_enter(body):
	# Hit the tilemap
	_hit_something()
