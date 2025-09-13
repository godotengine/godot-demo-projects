extends Pawn

@export var combat_actor: PackedScene
@export var pose_anims: SpriteFrames

var lost := false

@onready var pose := $Pivot/Slime

func _ready() -> void:
	pose.sprite_frames = pose_anims
	set_process(false)
