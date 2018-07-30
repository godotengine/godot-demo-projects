extends Node2D

# Member variables
# on-rails movement speed of the game area
const SPEED = 200
# current offset of the game area
var offset = 0

var motion = Vector2()

# reference to the actual ship that is controlled by the player
onready var player_ship = get_node("ship")

# the rail is moved during _fixed_process and should stop on player death
func stop():
	set_fixed_process(false)

func _fixed_process(delta):
	# move the rail at SPEED pixels per second
	translate(motion * delta)

func _ready():
	motion = Vector2(SPEED, 0)
	# connect the stop method to the player_ship's player_died signal
	player_ship.connect("player_died", self, "stop")
	# start processing
	set_fixed_process(true)
