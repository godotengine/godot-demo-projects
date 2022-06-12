extends Pawn

#warning-ignore:unused_class_variable
export(PackedScene) var combat_actor
#warning-ignore:unused_class_variable
var lost = false

func _ready():
	set_process(false)
