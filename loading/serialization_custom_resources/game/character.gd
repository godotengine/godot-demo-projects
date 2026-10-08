extends CharacterBody2D
class_name Character

const CHARACTER_GROUP := &"characters"

signal tagged(target : Character)

var move_direction : Vector2 = Vector2.ZERO
var path_to_whose_it : NodePath = ^""
var stunned : bool = false

@export var character_name := ""
@export var player_controlled := false
@export var base_speed : float = 100 # pixels per second
@export var it_speed_multiplier : float = 2.0
@export var stun_duration : float = 2.0 # seconds

@onready var timer := $StunTimer as Timer
@onready var label := $Label as Label


func _ready() -> void:
	label.text = character_name


func _physics_process(_delta: float) -> void:
	if player_controlled:
		move_direction = Input.get_vector("left", "right", "up", "down")
	elif is_it():
		move_direction = position.direction_to(get_nearest_character().position)
	else:
		var whose_it := get_node(path_to_whose_it) as Character
		move_direction = -1 * position.direction_to(whose_it.position) # move away from whose it
	velocity = move_direction * get_speed()
	var collided : bool = move_and_slide()
	if not collided: 
		return
	var collision : KinematicCollision2D = get_last_slide_collision()
	var collieder = collision.get_collider()
	if collieder is Character:
		if is_it() and not stunned:
			tagged.emit(collieder)


func is_it() -> bool:
	return path_to_whose_it == get_path()
	
	
func stun(duration : float) -> void:
	stunned = true
	timer.wait_time = duration
	timer.start()
	
	
func get_speed() -> float:
	if stunned: 
		return 0.0
	else:
		return base_speed * it_speed_multiplier if is_it() else base_speed
	
	
func get_nearest_character() -> Character:
	var nearest_character : Character = self
	var nearest_dist_squared := INF
	var dist_squared := 0.0
	
	var characters = get_tree().get_nodes_in_group(CHARACTER_GROUP)
	for character in characters as Array[Character]:
		dist_squared = position.distance_squared_to(character.position)
		if dist_squared > 0.0001 and dist_squared < nearest_dist_squared:
			nearest_dist_squared = dist_squared
			nearest_character = character
	return nearest_character


func serialize() -> CharacterResource:
	var character_resource := CharacterResource.new()
	character_resource.character_name = character_name
	character_resource.position = position
	character_resource.move_direction = move_direction
	character_resource.base_speed = base_speed
	character_resource.it_speed_multiplier = it_speed_multiplier
	character_resource.path_to_whose_it = path_to_whose_it
	character_resource.player_controlled = player_controlled
	character_resource.stunned = stunned
	character_resource.stun_duration = stun_duration
	character_resource.stun_time_left = timer.time_left
	return character_resource
	
	
func deserialize(character_resource : CharacterResource) -> void:
	if character_resource.stun_time_left > 0:
		timer.start(character_resource.stun_time_left)
	stun_duration = character_resource.stun_duration
	stunned = character_resource.stunned
	player_controlled = character_resource.player_controlled
	path_to_whose_it = character_resource.path_to_whose_it
	it_speed_multiplier = character_resource.it_speed_multiplier
	base_speed = character_resource.base_speed
	move_direction = character_resource.move_direction
	position = character_resource.position
	character_name = character_resource.character_name
	label.text = character_name


func _on_stun_timer_timeout() -> void:
	stunned = false
