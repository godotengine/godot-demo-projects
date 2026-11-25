extends Resource
class_name CharacterResource

@export var character_name : String

@export_group("Kinematic Variables")
@export var position : Vector2
@export var move_direction : Vector2
@export var base_speed : float # pixels per second
@export var it_speed_multiplier : float

@export_group("Game Variables")
@export_node_path("Character") var path_to_whose_it : NodePath
@export var player_controlled : bool
@export var stunned : bool
@export var stun_duration : float # seconds
@export var stun_time_left : float # seconds
