extends Node2D

var next_idx : int = 0
var troll : Node2D

@onready var troll_list := get_children()


func _ready() -> void:
    for t in troll_list:
        remove_child(t)
    spawn_next_troll()


func spawn_next_troll() -> void:
    troll = troll_list[next_idx]
    add_child(troll)
    next_idx += 1
    next_idx = next_idx % troll_list.size()


func _process(_dt : float) -> void:
    if Input.is_action_just_pressed("toggle_movement_method"):
        remove_child(troll)
        spawn_next_troll()
