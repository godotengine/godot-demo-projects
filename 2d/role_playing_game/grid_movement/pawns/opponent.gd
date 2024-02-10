extends Pawn


#warning-ignore:unused_class_variable
@export var combat_actor: PackedScene
#warning-ignore:unused_class_variable
var lost = false


func _ready():
	set_process(false)
