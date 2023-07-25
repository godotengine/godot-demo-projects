extends Button
# This script shows how to save data using Godot's custom ConfigFile format.
# ConfigFile can store any Variant type except Signal or Callable.


const SAVE_PATH = "user://save_config_file.ini"

## The root game node (so we can get and instance enemies).
@export var game_node: NodePath
## The player node (so we can set/get its health and position).
@export var player_node: NodePath


func save_game():
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

	(get_node(^"../LoadConfigFile") as Button).disabled = false


func load_game():
	var file_text := FileAccess.get_file_as_string(SAVE_PATH)
	# ConfigFile can deserialize objects, which can contain custom scripts.
	# Their _init methods are run immediately, so this check prevents executing
	# malicious code.
	# Players sometimes share save files online. If you're positive that files
	# will only come from a trustworthy source, you can skip this check.
	if file_text.contains("Object("):
		return
	var config := ConfigFile.new()
	config.parse(file_text)

	var player := get_node(player_node) as Player
	player.position = config.get_value("player", "position")
	player.health = config.get_value("player", "health")
	player.sprite.rotation = config.get_value("player", "rotation")

	# Remove existing enemies before adding new ones.
	get_tree().call_group("enemy", "queue_free")

	var enemies = config.get_value("enemies", "enemies")
	var game = get_node(game_node)

	for enemy_config in enemies:
		var enemy := preload("res://enemy.tscn").instantiate() as Enemy
		enemy.position = enemy_config.position
		game.add_child(enemy)
