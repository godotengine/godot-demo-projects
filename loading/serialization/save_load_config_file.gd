extends Button
# This script shows how to save data using Godot's custom ConfigFile format.
# ConfigFile can store any Variant type except Signal or Callable.
# It can even store Objects, but be extra careful where you deserialize them
# from, because they can include (potentially malicious) scripts.

const SAVE_PATH = "user://save_config_file.ini"

## The root game node (so we can get and instance enemies).
@export var game_node: NodePath
## The player node (so we can set/get its health and position).
@export var player_node: NodePath


func save_game() -> void:
	var config := ConfigFile.new()

	var player := get_node(player_node) as Player
	config.set_value("player", "position", player.position)
	config.set_value("player", "health", player.health)
	config.set_value("player", "rotation", player.sprite.rotation)

	var enemies := []
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		enemies.push_back({
			position = enemy.position,
		})
	config.set_value("enemies", "enemies", enemies)

	config.save(SAVE_PATH)

	($"../LoadConfigFile" as Button).disabled = false


func load_game() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	var player := get_node(player_node) as Player
	player.position = config.get_value("player", "position")
	player.health = config.get_value("player", "health")
	player.sprite.rotation = config.get_value("player", "rotation")

	# Remove existing enemies before adding new ones.
	get_tree().call_group("enemy", "queue_free")

	var enemies: Array = config.get_value("enemies", "enemies")
	var game := get_node(game_node)

	for enemy_config: Dictionary in enemies:
		var enemy := preload("res://enemy.tscn").instantiate() as Enemy
		enemy.position = enemy_config.position
		game.add_child(enemy)
