extends Node2D

onready var enemy_container = get_node("enemies")
onready var enemy_projectile_container = get_node("enemy_projectiles")

func _ready():
	var all_enemies = enemy_container.get_children()
	for enemy in all_enemies:
		# find all enemies who need a projectile container because they can shoot
		if enemy.has_method("set_projectile_container"):
			# tell those enemies about the container
			enemy.set_projectile_container(enemy_projectile_container)