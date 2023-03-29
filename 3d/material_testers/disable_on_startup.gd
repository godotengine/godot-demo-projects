extends Node

func _ready():
	var optionalNode = self;
	print(optionalNode.name);
	optionalNode.set_process(false);
	optionalNode.visible = false;
