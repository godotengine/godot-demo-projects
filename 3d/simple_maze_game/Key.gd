extends Spatial

const ROTATION_SPEED = 20
const WIN_SCREEN_PATH = "res://WinScreen.tscn"

var ready = false

func _ready():
	get_node("Area").connect("body_entered", self, "body_entered_trigger")
	set_process(true)
  
func _process(delta):
	rotation_degrees.y += delta * ROTATION_SPEED


func body_entered_trigger(body):
	if ready:
		if body.get_name() == "Player":
			get_tree().change_scene(WIN_SCREEN_PATH)
