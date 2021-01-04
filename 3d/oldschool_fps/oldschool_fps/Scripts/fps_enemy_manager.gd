class_name FPSEnemyManager
extends Node
# class cycles through spawn points and pooled enemies, spawns a specified number of enemies at the start
# then when they're all killed, it spawns another wave


const DEFAULT_ENEMY_SPAWN_POINT = Vector3(0, -100, 0)

export(int) var starting_num_of_enemies = 1

var enemies_in_level
var spawn_locations

var spawn_location_index = 0

var num_of_enemies_in_wave = starting_num_of_enemies


# Called when the node enters the scene tree for the first time.
func _ready():

	spawn_locations = get_node("SpawnPoints").get_children()
	enemies_in_level = get_node("Enemies").get_children()

	for i in starting_num_of_enemies:
		enemies_in_level[i].set_translation(spawn_locations[i % spawn_locations.size() - 1].global_transform.origin)
		enemies_in_level[i].active = true

	spawn_location_index = starting_num_of_enemies - 1


# if one enemy is still active this will return out before spawning a new wave
func handle_death():
	for i in enemies_in_level.size():
		if enemies_in_level[i].active:
			return
	spawn_new_enemy_wave()


func spawn_new_enemy_wave():
	num_of_enemies_in_wave += 1
	if num_of_enemies_in_wave == enemies_in_level.size():
		num_of_enemies_in_wave = 1
	for i in num_of_enemies_in_wave:
		if spawn_location_index == spawn_locations.size():
			spawn_location_index = 0
		enemies_in_level[i].set_translation(spawn_locations[spawn_location_index].global_transform.origin)
		enemies_in_level[i].active = true
		spawn_location_index += 1
