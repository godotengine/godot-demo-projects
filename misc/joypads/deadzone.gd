extends HBoxContainer

const MAX_DEADZONE_SPRITE_SCALE:float = 1.5
const PATH_TO_MASK:String = "Axis_Sprite/Mask"
const PATH_TO_ROOT:String = "../../"

var deadzone_sprite:Sprite = null
var root_node:Node = null

func _ready():
	self.deadzone_sprite = self.get_node(self.PATH_TO_MASK)
	self.root_node = self.get_node(self.PATH_TO_ROOT)

func _on_SpinBox_value_changed(value):
	var percentage_value:float = value * 0.01
	self.deadzone_sprite.scale.y = self.MAX_DEADZONE_SPRITE_SCALE * percentage_value
	self.deadzone_sprite.scale.x = self.deadzone_sprite.scale.y
	self.root_node.deadzone = percentage_value
