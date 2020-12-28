extends Button
# This script shows how to save data using the JSON file format.
# JSON is a widely used file format, but not all Godot types can be
# stored natively. For example, integers get converted into doubles,
# and to store Vector2 and other non-JSON types you need `var2str()`.

# The root game node (so we can get and instance enemies).
export(NodePath) var game_node
# The player node (so we can set/get its health and position).
export(NodePath) var player_node

const SAVE_PATH = "user://save_json.json"


func save_game():
	var file = File.new()
	file.open(SAVE_PATH, File.WRITE)

	var player = get_node(player_node)
	# JSON doesn't support complex types such as Vector2.
	# `var2str()` can be used to convert any Variant to a String.
	var save_dict = {
		player = {
			position = var2str(player.position),
			health = var2str(player.health),
		},
		enemies = []
	}

	for enemy in get_tree().get_nodes_in_group("enemy"):
		save_dict.enemies.push_back({
			position = var2str(enemy.position),
		})

	file.store_line(to_json(save_dict))

	get_node("../LoadJSON").disabled = false


# `load()` is reserved.
func load_game():
	var file = File.new()
	file.open(SAVE_PATH, File.READ)
	var save_dict = parse_json(file.get_line())

	var player = get_node(player_node)
	# JSON doesn't support complex types such as Vector2.
	# `str2var()` can be used to convert a String to the corresponding Variant.
	player.position = str2var(save_dict.player.position)
	player.health = str2var(save_dict.player.health)

	# Remove existing enemies and add new ones.
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()

	# Ensure the node structure is the same when loading.
	var game = get_node(game_node)

	for enemy_config in save_dict.enemies:
		var enemy = preload("res://enemy.tscn").instance()
		enemy.position = str2var(enemy_config.position)
		game.add_child(enemy)
