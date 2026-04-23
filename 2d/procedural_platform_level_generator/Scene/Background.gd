extends TextureRect

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"../Player"
	position.x = player.position.x - 120

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player!=null:
		position.x = player.position.x - 120

