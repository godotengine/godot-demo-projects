extends Node2D

var next_index: int = 0
var troll: Node2D

@onready var troll_list: Array[Node] = get_children()


func _ready() -> void:
    for t in troll_list:
        remove_child(t)
    spawn_next_troll()
    troll.become_active_troll()


func spawn_next_troll() -> void:
    troll = troll_list[next_index]
    add_child(troll)
    next_index += 1
    next_index = next_index % troll_list.size()


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed(&"toggle_movement_method"):
        var pos: Vector2 = troll.global_position
        remove_child(troll)
        spawn_next_troll()
        troll.global_position = pos
        troll.become_active_troll()
