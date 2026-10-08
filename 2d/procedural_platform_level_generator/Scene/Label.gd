extends Label

var score = 0
var print_score = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	print_score = str(score)
	text = print_score

func _on_score():
	score += 1
	print_score = str(score)
	text = print_score
