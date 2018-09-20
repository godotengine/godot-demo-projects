extends 'Pawn.gd'

export (PackedScene) var combat_actor
var lost = false

func _ready():
	set_process(false)
