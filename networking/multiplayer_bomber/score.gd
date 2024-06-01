extends HBoxContainer

var player_labels := {}

func _process(_delta: float) -> void:
	var rocks_left := $"../Rocks".get_child_count()
	if rocks_left == 0:
		var winner_name := ""
		var winner_score := 0
		for p: int in player_labels:
			if player_labels[p].score > winner_score:
				winner_score = player_labels[p].score
				winner_name = player_labels[p].name

		$"../Winner".set_text("THE WINNER IS:\n" + winner_name)
		$"../Winner".show()


func increase_score(for_who: int) -> void:
	assert(for_who in player_labels)

	var pl: Dictionary = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.name + "\n" + str(pl.score))


func add_player(id: int, new_player_name: String) -> void:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = new_player_name + "\n" + "0"
	label.modulate = gamestate.get_player_color(new_player_name)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.add_theme_font_override("font", preload("res://montserrat.otf"))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 9)
	label.add_theme_font_size_override("font_size", 18)
	add_child(label)

	player_labels[id] = {
		name = new_player_name,
		label = label,
		score = 0,
	}


func _ready() -> void:
	$"../Winner".hide()


func _on_exit_game_pressed() -> void:
	gamestate.end_game()
