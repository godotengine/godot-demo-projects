extends Resource
class_name RefereeResource

@export_node_path("Character") var path_to_whose_it : NodePath
@export_node_path("Character") var path_to_who_starts_as_it : NodePath

@export var player_resource : CharacterResource
@export var other_alice_resource : CharacterResource
@export var other_bob_resource : CharacterResource

@export var prompt_text : String
