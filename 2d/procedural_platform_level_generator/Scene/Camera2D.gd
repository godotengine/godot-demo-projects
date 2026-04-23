extends Camera2D


var camera_speed = 2 # the speed of the camera movement
var player
var target_pos
func _ready():
	player = $"../Player"
	target_pos = Vector2(player.position.x+400, 200)

func _physics_process(delta):
	# get the target position of the camera based on the player position and the offset
	if player!=null:
		target_pos = Vector2(player.position.x+400, 200)
	# lerp the current position of the camera to the target position with a smoothing factor
	position = position.lerp(target_pos, delta * camera_speed)
