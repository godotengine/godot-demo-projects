extends Node2D

# the rail's horizontal movement speed
const SPEED = -200

# used to store this enemy rail's motion direction
var motion = Vector2()

# keep references to child nodes
onready var ship = get_node("area")
onready var visibility = get_node("area/visibility")

signal enemy_died(score)

func _ready():
	# connect to the actual ship's death signal so it can be relayed further up the tree
	# the relay is required because the player collides with the ship's area node, but the level connects to each enemy scene's root node
	ship.connect("enemy_died", self, "on_ship_died")
	# once the ship is in range, start moving the rail
	visibility.connect("enter_screen", self, "set_fixed_process", [true])
	# once the ship leaves the screen, remove the entire node
	visibility.connect("exit_screen", self, "queue_free")
	motion = Vector2(SPEED, 0)

func _fixed_process(delta):
	# constant movement
	translate(motion * delta)

func on_ship_died(score):
	# stop moving the rail
	set_fixed_process(false)
	# relay the death signal upwards
	emit_signal("enemy_died", score)
