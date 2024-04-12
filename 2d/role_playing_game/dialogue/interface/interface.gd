extends Control


var dialogue_node = null


func _ready():
	hide()


func show_dialogue(player, dialogue):
	show()
	$Button.grab_focus()
	dialogue_node = dialogue
	for c in dialogue.get_signal_connection_list("dialogue_started"):
		if player == c.callable.get_object():
			dialogue_node.start_dialogue()
			$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
			$Text.text = dialogue_node.dialogue_text
			return
	dialogue_node.dialogue_started.connect(player.set_active.bind(false))
	dialogue_node.dialogue_finished.connect(player.set_active.bind(true))
	dialogue_node.dialogue_finished.connect(hide)
	dialogue_node.dialogue_finished.connect(_on_dialogue_finished.bind(player))
	dialogue_node.start_dialogue()
	$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	$Text.text = dialogue_node.dialogue_text


func _on_Button_button_up():
	dialogue_node.next_dialogue()
	$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	$Text.text = dialogue_node.dialogue_text


func _on_dialogue_finished(player):
	dialogue_node.dialogue_started.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(hide)
	dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
