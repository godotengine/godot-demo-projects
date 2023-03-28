extends Panel


var coins_collected = 0

onready var coins_label = $Label


func _ready():
	coins_label.set_text(str(coins_collected))
	# Static types are necessary here to avoid warnings.
	var anim_sprite: AnimatedSprite = $AnimatedSprite
	anim_sprite.play()
	# Check if the game is in splitscreen mode by checking the scene root name.
	if get_tree().get_root().get_child(0).name == "Splitscreen":
		var _level_node = get_node(@"../../../../Black/SplitContainer/ViewportContainer1/Viewport1/Level")
		_level_node.get_node("Player1").connect("collect_coin", self, "_collect_coin")
		_level_node.get_node("Player2").connect("collect_coin", self, "_collect_coin")
	else:
		var _player_path = get_node(@"../../../../Level/Player")
		_player_path.connect("collect_coin", self, "_collect_coin")


func _collect_coin():
	coins_collected += 1
	coins_label.set_text(str(coins_collected))
