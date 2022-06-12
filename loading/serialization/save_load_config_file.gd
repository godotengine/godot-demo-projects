extends Button
# This script shows how to save data using Godot's custom ConfigFile format.
# ConfigFile can store any Godot type natively.

# The root game node (so we can get and instance enemies).
export(NodePath) var game_node
# The player node (so we can set/get its health and position).
export(NodePath) var player_node

const SAVE_PATH = "user://save_config_file.ini"


func save_game():
	var config = ConfigFile.new()

	var player = get_node(player_node)
	config.set_value("player", "position", player.position)
	config.set_value("player", "health", player.health)

	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemies.push_back({
			position = enemy.position,
		})
	config.set_value("enemies", "enemies", enemies)

	config.save(SAVE_PATH)

	get_node("../LoadConfigFile").disabled = false


# `load()` is reserved.
func load_game():
	var config = ConfigFile.new()
	config.load(SAVE_PATH)

	var player = get_node(player_node)
	player.position = config.get_value("player", "position")
	player.health = config.get_value("player", "health")

	# Remove existing enemies and add new ones.
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()

	var enemies = config.get_value("enemies", "enemies")
	# Ensure the node structure is the same when loading.
	var game = get_node(game_node)

	for enemy_config in enemies:
		var enemy = preload("res://enemy.tscn").instance()
		enemy.position = enemy_config.position
		game.add_child(enemy)
