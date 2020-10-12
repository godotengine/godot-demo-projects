extends Control

func _ready():
	var tree = $"TabContainer/Text direction/Tree"
	var root = tree.create_item()
	tree.set_hide_root(true)
	var first = tree.create_item(root)
	first.set_text(0, "רֵאשִׁית")
	var second = tree.create_item(first)
	second.set_text(0, "שֵׁנִי")
	var third = tree.create_item(second)
	third.set_text(0, "שְׁלִישִׁי")
	var fourth = tree.create_item(third)
	fourth.set_text(0, "fourth")

func _on_Tree_item_selected():
	var tree = $"TabContainer/Text direction/Tree"
	var path = ""
	var item = tree.get_selected()
	while item != null:
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	$"TabContainer/Text direction/LineEditST".text = path
	$"TabContainer/Text direction/LineEditNoST".text = path

func _on_LineEditCustomSTDst_text_changed(new_text):
	$"TabContainer/Text direction/LineEditCustomSTSource".text = new_text

func _on_LineEditCustomSTSource_text_changed(new_text):
	$"TabContainer/Text direction/LineEditCustomSTDst".text = new_text

func _on_LineEditCustomSTDst_tree_entered():
	$"TabContainer/Text direction/LineEditCustomSTDst".text = $"TabContainer/Text direction/LineEditCustomSTSource".text # Refresh text to apply custom script once it's loaded.
