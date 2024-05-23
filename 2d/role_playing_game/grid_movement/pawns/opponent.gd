extends Pawn

@export var combat_actor: PackedScene
var lost := false

func _ready() -> void:
	set_process(false)
