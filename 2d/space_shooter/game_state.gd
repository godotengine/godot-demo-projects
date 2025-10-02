# Script has to extend any Node class because it's an Autoload
# Autoloads are put into the Scene Tree, and only Nodes can live there
extends Node

# points in current round
var points = 0
# maximum points ever achieved
var max_points = 0

# file path to the highscore file, stored in the user directory
# see the docs for the actual path, which depends on operating system / platform
# http://docs.godotengine.org/en/2.1/learning/features/misc/data_paths.html
const HIGHSCORE_PATH = "user://highscore"

# preloading the game's menu and actual game screen
const main_menu_scene = preload("res://main_menu/main_menu.tscn")
const main_level_scene = preload("res://game_screen/level/level.tscn")

var menu
var game

func _ready():
	# Load high score
	_load_high_score()

func start_game():
	# reset the points
	points = 0
	_reset_game()

	# instance the game scene
	game = main_level_scene.instance()
	# tell the scene tree to switch the current scene
	get_tree().get_root().add_child(game)

func abort_game():
	_reset_game()

	menu = main_menu_scene.instance()
	get_tree().get_root().add_child(menu)

func game_over():
	if (points > max_points):
		max_points = points
		# Save high score
		_save_high_score()

func _reset_game():
	if game != null:
		game.hide()
		game.queue_free()
		game = null

	if menu != null:
		menu.hide()
		menu.queue_free()
		menu = null

func _load_high_score():
	# start off with 0 max points in a fresh game
	max_points = 0
	# initialize a file handler
	var f = File.new()
	# check for existing highscore file
	if f.file_exists(HIGHSCORE_PATH):
		# if it exists, try to open the file in READ mode
		if f.open(HIGHSCORE_PATH, File.READ) == OK:
			# read the current high score as a godot Variant and store it in max_points
			max_points = f.get_var()
	# always close the file handle
	f.close()

func _save_high_score():
	var f = File.new()
	# try to open the highscore file in WRITE mode, which creates a new file if it doesn't exist
	if f.open(HIGHSCORE_PATH, File.WRITE) == OK:
		# store the max points as a godot Variant
		f.store_var(max_points)
	# always close the file handle
	f.close()
