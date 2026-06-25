extends Node
class_name Referee

var path_to_whose_it : NodePath

@export_file("*.tres; resource", "*.json; json") var save_file : String = "" #haven't done json yet
@export_node_path("Character") var path_to_who_starts_as_it := ^"GameLayer/Player"

@onready var player := %Player as Character
@onready var other_alice := %OtherAlice as Character
@onready var other_bob := %OtherBob as Character

@onready var prompt := %Prompt as Prompt
@onready var file_dialogue := %FileDialogue as FileDialog


func _ready() -> void:
	var whose_it := get_node(path_to_who_starts_as_it) as Character
	update_whose_it(whose_it)
	
	if save_file != "":
		open(save_file)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		file_dialogue.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialogue.visible = true
	elif event.is_action_pressed("open"):
		file_dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialogue.visible = true


func update_whose_it(whose_it : Character) -> void:
	prompt.show_whose_it(whose_it.character_name)
	path_to_whose_it = whose_it.get_path()
	var characters = get_tree().get_nodes_in_group(Character.CHARACTER_GROUP)
	for character in characters as Array[Character]:
		character.path_to_whose_it = path_to_whose_it
		
		
func tag_character(character_tagged : Character) -> void:
	character_tagged.stun(character_tagged.stun_duration)
	update_whose_it(character_tagged)
	
	
func serialize() -> RefereeResource:
	var referee_resource := RefereeResource.new()
	referee_resource.path_to_whose_it = path_to_whose_it
	referee_resource.path_to_who_starts_as_it = path_to_who_starts_as_it
	referee_resource.player_resource = player.serialize()
	referee_resource.other_alice_resource = other_alice.serialize()
	referee_resource.other_bob_resource = other_bob.serialize()
	referee_resource.prompt_text = prompt.text
	return referee_resource
	
	
func deserialize(referee_resource : RefereeResource) -> void:
	prompt.text = referee_resource.prompt_text
	other_bob.deserialize(referee_resource.other_bob_resource)
	other_alice.deserialize(referee_resource.other_alice_resource)
	player.deserialize(referee_resource.player_resource)
	path_to_who_starts_as_it = referee_resource.path_to_who_starts_as_it
	path_to_whose_it = referee_resource.path_to_whose_it
	update_whose_it(get_node(path_to_whose_it))
	
	
func save(file_name : String) -> void:
	var referee_resource : RefereeResource = serialize()
	ResourceSaver.save(referee_resource, file_name)
	
	
func open(file_name : String) -> void:
	var referee_resource := load(file_name) as RefereeResource
	deserialize(referee_resource)


func _on_player_tagged(target : Character) -> void:
	tag_character(target)


func _on_other_alice_tagged(target : Character) -> void:
	tag_character(target)


func _on_other_bob_tagged(target : Character) -> void:
	tag_character(target)


func _on_file_dialogue_file_selected(path: String) -> void:
	match file_dialogue.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:
			save(path)
		FileDialog.FILE_MODE_OPEN_FILE:
			open(path)


func _on_file_dialogue_visibility_changed() -> void:
	var pause : bool = file_dialogue.visible
	$GameLayer.process_mode = Node.PROCESS_MODE_DISABLED if pause else Node.PROCESS_MODE_INHERIT
