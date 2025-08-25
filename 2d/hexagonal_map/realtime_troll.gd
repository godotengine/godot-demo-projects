extends CharacterBody2D

const MOTION_SPEED = 30
const FRICTION_FACTOR = 0.89
const TAN30DEG = tan(deg_to_rad(30))


@export var gridlayer : TileMapLayer


func _physics_process(_delta: float) -> void:
	var prev_position := global_position

	var motion := Vector2()
	motion.x = Input.get_axis("move_left", "move_right")
	motion.y = Input.get_axis("move_up", "move_down")
	# Make diagonal movement fit for hexagonal tiles.
	motion.y *= TAN30DEG
	velocity += motion.normalized() * MOTION_SPEED
	# Apply friction.
	velocity *= FRICTION_FACTOR
	move_and_slide()


	# Prevent movement off of the grid tiles. Alternatively, you could add a
	# border tile around the outside of your world with physics enabled in the
	# TileMapLayer. That would allow nice sliding along the walls of the world.
	var dest_tile : int = gridlayer.get_world_tile(global_position)
	var has_tile := dest_tile >= 0
	if not has_tile:
		global_position = prev_position
