extends Node2D

@export var character_speed: float = 400.0
var path = []

@onready var character = $Character

#var navmap = NavigationServer2D.map_create()


func _ready():
	pass
	#NavigationServer2D.region_set_map(navmap, $NavigationRegion2d.get_rid())


func _process(delta):
	character.position = $NavigationAgent2d.get_next_location()
	var walk_distance = character_speed * delta
	#move_along_path(walk_distance)


# The "click" event is a custom input action defined in
# Project > Project Settings > Input Map tab.
func _unhandled_input(event):
	if not event.is_action_pressed("click"):
		return
	_update_navigation_path(Vector2(), get_local_mouse_position())

#func move_along_path(distance):
#	return
#	var last_point = character.position
#	while path.size():
#		var distance_between_points = last_point.distance_to(path[0])
#		# The position to move to falls between two points.
#		if distance <= distance_between_points:
#			character.position = last_point.lerp(path[0], distance / distance_between_points)
#			return
#		# The position is past the end of the segment.
#		distance -= distance_between_points
#		last_point = path[0]
#		path.remove(0)
#	# The character reached the end of the path.
#	character.position = last_point
#	set_process(false)

var drawpos = Vector2()
func _update_navigation_path(start_position, end_position):
	# get_simple_path is part of the Node2D class.
	# It returns a PackedVector2Array of points that lead you
	# from the start_position to the end_position.
	$NavigationAgent2d.set_target_location(end_position)
	drawpos = end_position
	queue_redraw()
	# The first point is always the start_position.
	# We don't need it in this example as it corresponds to the character's position.
	#path.remove(0)
	#set_process(true)

func _draw():
	draw_circle(drawpos, 10, Color.RED)
