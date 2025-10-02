extends CharacterBody2D

## The player's movement speed (in pixels per second).
const MOTION_SPEED = 90.0

## The delay before which you can place a new bomb (in seconds).
const BOMB_RATE = 0.5

@export var synced_position := Vector2()

@export var stunned := false

var last_bomb_time := BOMB_RATE
var current_anim := ""

@onready var inputs: Node = $Inputs

func _ready() -> void:
	stunned = false
	position = synced_position
	if str(name).is_valid_int():
		$"Inputs/InputsSync".set_multiplayer_authority(str(name).to_int())


func _physics_process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		# The client which this player represent will update the controls state, and notify it to everyone.
		inputs.update()

	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		# The server updates the position that will be notified to the clients.
		synced_position = position
		# And increase the bomb cooldown spawning one if the client wants to.
		last_bomb_time += delta
		if not stunned and is_multiplayer_authority() and inputs.bombing and last_bomb_time >= BOMB_RATE:
			last_bomb_time = 0.0
			$"../../BombSpawner".spawn([position, str(name).to_int()])
	else:
		# The client simply updates the position to the last known one.
		position = synced_position

	if not stunned:
		# Everybody runs physics. i.e. clients try to predict where they will be during the next frame.
		velocity = inputs.motion * MOTION_SPEED
		move_and_slide()

	# Also update the animation based on the last known player input state.
	var new_anim := &"standing"

	if inputs.motion.y < 0:
		new_anim = &"walk_up"
	elif inputs.motion.y > 0:
		new_anim = &"walk_down"
	elif inputs.motion.x < 0:
		new_anim = &"walk_left"
	elif inputs.motion.x > 0:
		new_anim = &"walk_right"

	if stunned:
		new_anim = &"stunned"

	if new_anim != current_anim:
		current_anim = new_anim
		$anim.play(current_anim)


@rpc("call_local")
func set_player_name(value: String) -> void:
	$label.text = value
	# Assign a random color to the player based on its name.
	$label.modulate = gamestate.get_player_color(value)
	$sprite.modulate = Color(0.5, 0.5, 0.5) + gamestate.get_player_color(value)


@rpc("call_local")
func exploded(_by_who: int) -> void:
	if stunned:
		return

	stunned = true
	$anim.play("stunned")
