extends TileMap

@export var screenWidth = 800   # You can change this as screenWidth = get_viewport_rect().size.x, I kept it this to see the generation and deletion of tile in screen
var tile_size = Vector2(80, 16)
var player
var LineTileIndex = 0   # Index of tile1 in the TileSet
var PlateTileIndex = 1   # Index of tile2 in the TileSet
var next_tile_position
var prev_tile_position
const y_pos = 11 # Can also calculate this from screenHeight/(2*cell_size.y) if you want responsive
var playerPosition
signal game_over
signal score
var game_over_signal = false
var playerCellPos
var Interacted_Tile_Index

func _ready():
	player = $"../Player"
	playerPosition = player.position
	next_tile_position = map_to_local(Vector2i(0, y_pos))
	prev_tile_position = map_to_local(Vector2i(-1, y_pos))
	generate_tiles()

func generate_tiles():
	while next_tile_position.x < (playerPosition.x + screenWidth):
		var value = randi_range(1,5)
		for i in range(value):
			set_cell(0, local_to_map(next_tile_position), LineTileIndex, Vector2i(0,0))
			next_tile_position.x += tile_size.x
		set_cell(0, local_to_map(next_tile_position), PlateTileIndex, Vector2i(0,0))
		next_tile_position.x += tile_size.x

func remove_cells():
	while prev_tile_position.x < playerPosition.x - 160.0:
		erase_cell(0, local_to_map(prev_tile_position))
		prev_tile_position.x += tile_size.x

func _process(delta):
	if player!=null:
		playerPosition = player.position

	if next_tile_position.x < (playerPosition.x + screenWidth):
		generate_tiles()

	if prev_tile_position.x < playerPosition.x - 160.0:
		remove_cells()

	# Check for collision with tile1
	playerCellPos = local_to_map(playerPosition)
	Interacted_Tile_Index = get_cell_source_id(0, playerCellPos)

	if Interacted_Tile_Index == PlateTileIndex:
		# Obstacle indexed 1 tile
		$"../Hit_sound".play()
		set_cell(0, playerCellPos, -1)
		emit_signal("score")

	elif Interacted_Tile_Index == LineTileIndex:
		# Line indexed 0 tile
		if not game_over_signal:
			game_over_signal = true
			emit_signal("game_over")
