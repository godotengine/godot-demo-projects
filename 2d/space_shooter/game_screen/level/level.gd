extends Node2D

onready var hud = get_node("hud")
onready var player_rail = get_node("player_ship_on_rail")
onready var player_ship = player_rail.player_ship
onready var level_map = get_node("level_map")
onready var projectiles = get_node("projectiles")

func _ready():
	# tell the player ship where to instance its projectiles
	player_ship.set_projectile_container(projectiles)
	# connect to the player's death signal
	player_ship.connect("player_died", self, "on_player_died")
	# find all enemies in the currently loaded level and connect to their death signals for scoring
	for enemy in level_map.enemy_container.get_children():
		# for instances of enemy1, this check is being done against their root "rail" Node2D
		# the actual collision later checks their area's group
		if enemy.is_in_group("enemy"):
			enemy.connect("enemy_died", self, "on_enemy_died")
	hud.connect("return_to_menu", self, "on_return_to_menu")

# notifies the hud and game state about the player's death
func on_player_died():
	game_state.game_over()
	hud.game_over()

# notifies the game_state and hud about enemy deaths, which report the enemy's point value
func on_enemy_died(score):
	game_state.points += score
	hud.update_score(game_state.points)

func on_return_to_menu():
	game_state.abort_game()
