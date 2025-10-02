extends CanvasLayer

onready var score_label = get_node("score_points")
onready var return_button = get_node("back_to_menu")
onready var game_over_label = get_node("game_over")

signal return_to_menu

func _ready():
	return_button.connect("pressed", self, "_on_return_to_menu")
	set_process(true)
	set_process_input(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		_on_return_to_menu()

func update_score(score):
	score_label.set_text(str(score))

func _on_return_to_menu():
	emit_signal("return_to_menu")

func game_over():
	game_over_label.show()
