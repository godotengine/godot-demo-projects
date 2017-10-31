extends RayCast2D

var distance_hit = 0
var hit = false

func _ready():
	set_enabled(true) # RayCasts are disabled by default
	set_physics_process(true)

# Process raycast updates every physics frame
func _physics_process(dt):
	if is_colliding():
		distance_hit = (get_collision_point()-position).length()
		hit = true
		# Notify the object, using signals is recommended
		get_collider().emit_signal("raycast_hit")
	else:
		distance_hit = 1000 # Forces the drawn line to reach off-screen
		hit = false
	update() # Causes a re-draw

func _draw():
	var color = Color(255, 0, 0) # Color when not hit
	if hit:
		color = Color(0, 255, 0) # Color when hit
	draw_line(Vector2(0,0), Vector2(0,distance_hit), color)