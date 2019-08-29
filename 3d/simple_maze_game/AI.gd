extends Navigation

# How fast we are moving
const SPEED_NORMAL = 1.5
const SPEED_RUN = 3

# The path
var route_path = []
# Should we optimize the path
var path_optimize = false

var player
var seen_player = false
var agent
var has_setup = false;

var update_timer = 1
const UPDATE_TIME = 2

const LOSE_SCREEN_PATH = "res://LoseScreen.tscn"


func _ready():
	#warning-ignore-all:return_value_discarded
	get_node("Agent/VisionArea").connect("body_entered", self, "body_entered_vision")
	get_node("Agent/VisionArea").connect("body_exited", self, "body_exited_vision")
	get_node("Agent/GrabArea").connect("body_entered", self, "body_entered_grab")
	
	set_physics_process(false)
	
	return


func setup(position):
	agent = get_node("Agent")
	player = get_parent().get_node("Player")
	agent.global_transform.origin = position
	set_physics_process(true)
	has_setup = true;


func _physics_process(delta):
	# We only want to update our path to the player every five seconds
	# so we'll make a simple timer
	if update_timer <= 0:
		update_timer += UPDATE_TIME
		
		# If we have a player and the player has an origin, then we should move towards it
		if player != null:
			var p_origin = player.transform.origin
			if p_origin != null:
				set_path()
	else:
		update_timer -= delta


func _process(delta):
	# If we have a path to follow
	if route_path.size() > 1:
		
		# Move faster when we've seen the player
		var to_walk = delta
		if seen_player:
			to_walk *= SPEED_RUN
		else:
			to_walk *= SPEED_NORMAL
		
		var to_watch = Vector3.UP
		while to_walk > 0 and route_path.size() >= 2:
			var pfrom = route_path[route_path.size() - 1]
			var pto = route_path[route_path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if d <= to_walk:
				route_path.remove(route_path.size() - 1)
				to_walk -= d
			else:
				route_path[route_path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
		
		var atpos = route_path[route_path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		# Set our transform to the correct position on the path.
		var t = Transform()
		t.origin = atpos
		t.origin.y = 0
		t=t.looking_at(atpos + atdir, Vector3.UP)
		agent.global_transform = t
		
		# If there is less than two points on the path, then we've reached the end of the path
		if route_path.size() < 2:
			route_path = []
			set_process(false)
	
	else:
		set_process(false)


func set_path():
	# The path should begin at the closest point to our agent
	var path_begin = get_closest_point(agent.global_transform.origin)
	
	# And we want to arrive at the player's position
	var player_pos = player.global_transform.origin
	var path_end = get_closest_point(player_pos)
	
	# Get a simple path, convert it into an array (for easier access) and invert the path
	var p = get_simple_path(path_begin, path_end, path_optimize)
	route_path = Array(p)
	route_path.invert()
	
	set_process(true)


func body_entered_vision(body):
	if has_setup == true:
		if body.get_name() == "Player":
			seen_player = true


func body_exited_vision(body):
	if has_setup == true:
		if body.get_name() == "Player":
			seen_player = false


func body_entered_grab(body):
	if has_setup == true:
		if body.get_name() == "Player":
			get_tree().change_scene(LOSE_SCREEN_PATH)

