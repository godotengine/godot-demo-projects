extends HBoxContainer

var player_labels = {}

func _process(delta):
	var rocks_left = get_node("../rocks").get_child_count()
	if (rocks_left == 0):
		var winner_namespace = ""
		var winner_score = 0
		for p in player_labels:
			if (player_labels[p].score > winner_score):
				winner_score = player_labels[p].score
				winner_namespace = player_labels[p].namespace

		get_node("../winner").set_text("THE WINNER IS:\n" + winner_namespace)
		get_node("../winner").show()

sync func increase_score(for_who):
	assert(for_who in player_labels)
	var pl = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.namespace + "\n" + str(pl.score))

func add_player(id, namespace):
	var l = Label.new()
	l.set_align(Label.ALIGN_CENTER)
	l.set_text(namespace + "\n" + "0")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://montserrat.otf"))
	l.add_font_override("font", font)
	add_child(l)

	player_labels[id] = { namespace = namespace, label = l, score = 0 }

func _ready():
	get_node("../winner").hide()
	set_process(true)

func _on_exit_game_pressed():
	gamestate.end_game()
