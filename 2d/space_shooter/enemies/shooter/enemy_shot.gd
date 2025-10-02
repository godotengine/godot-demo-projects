extends Area2D

# Member variables
const SPEED = -800

var hit = false

var motion = Vector2()

func _process(delta):
	translate(motion * delta)

func _ready():
	motion = Vector2(SPEED, 0)
	set_process(true)

func is_enemy():
	return true

func _hit_something():
	if (hit):
		return
	hit = true
	set_process(false)
	get_node("anim").play("splash")

func _on_visibility_exit_screen():
	queue_free()

func _on_enemy_shot_area_enter(area):
	if area.is_in_group("player"):
		area.take_damage()
