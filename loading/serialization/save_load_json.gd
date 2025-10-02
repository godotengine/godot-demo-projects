extends Button
# This script shows how to save data using the JSON file format.
# JSON is a widely used file format, but not all Godot types can be
# stored natively. For example, integers get converted into doubles,
# and to store Vector2 and other non-JSON types you need to convert
# them, such as to a String using var_to_str.

## The root game node (so we can get and instance enemies).
@export var game_node: NodePath
## The player node (so we can set/get its health and position).
@export var player_node: NodePath

const SAVE_PATH = "user://save_json.json"

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	var player := get_node(player_node)
	# JSON doesn't support many of Godot's types such as Vector2.
	# var_to_str can be used to convert any Variant to a String.
	var save_dict := {
		player = {
			position = var_to_str(player.position),
			health = var_to_str(player.health),
			rotation = var_to_str(player.sprite.rotation),
		},
		enemies = [],
	}

	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		save_dict.enemies.push_back({
			position = var_to_str(enemy.position),
		})

	file.store_line(JSON.stringify(save_dict))

	get_node(^"../LoadJSON").disabled = false


func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Dictionary

	var player := get_node(player_node) as Player
	# JSON doesn't support many of Godot's types such as Vector2.
	# str_to_var can be used to convert a String to the corresponding Variant.
	player.position = str_to_var(save_dict.player.position)
	player.health = str_to_var(save_dict.player.health)
	player.sprite.rotation = str_to_var(save_dict.player.rotation)

	# Remove existing enemies before adding new ones.
	get_tree().call_group("enemy", "queue_free")

	# Ensure the node structure is the same when loading.
	var game := get_node(game_node)

	for enemy_config: Dictionary in save_dict.enemies:
		var enemy: Enemy = preload("res://enemy.tscn").instantiate()
		enemy.position = str_to_var(enemy_config.position)
		game.add_child(enemy)
