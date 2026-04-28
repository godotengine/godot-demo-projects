@tool
extends Tree


func _ready() -> void:
	var root: TreeItem = create_item()
	root.set_text(0, "Tree - Root TreeItem")
	var image := preload("res://icon.webp").get_image()
	image.resize(16, 16)
	root.add_button(0, ImageTexture.create_from_image(image), -1, false, "Example TreeItem button.")
	root.add_button(0, ImageTexture.create_from_image(image), -1, true, "Example disabled TreeItem button.")

	var child1: TreeItem = create_item(root)
	child1.set_text(0, "Tree - TreeItem 1")
	var child2: TreeItem = create_item(root)
	child2.set_text(0, "Tree - TreeItem 2")
	var subchild1: TreeItem = create_item(child1)
	subchild1.set_text(0, "Tree - TreeItem 1 Child")
