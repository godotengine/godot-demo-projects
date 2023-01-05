extends Control

var dialogue_node = null

func _ready():
	hide()


func show_dialogue(player, dialogue):
	show()
	$Button.grab_focus()
	dialogue_node = dialogue
	for c in dialogue.get_signal_connection_list("dialogue_finished"):
		if self == c.target:
			dialogue_node.start_dialogue()
			break
			return
	dialogue_node.dialogue_started.connect(player.set_active.bind(false))
	dialogue_node.dialogue_finished.connect(player.set_active.bind(true))
	dialogue_node.dialogue_finished.connect(self.hide)
	dialogue_node.dialogue_finished.connect(self._on_dialogue_finished.bind(player))
	dialogue_node.start_dialogue()
	$Name.text = dialogue_node.dialogue_name
	$Text.text = dialogue_node.dialogue_text


func _on_Button_button_up():
	dialogue_node.next_dialogue()
	$Name.text = dialogue_node.dialogue_name
	$Text.text = dialogue_node.dialogue_text


func _on_dialogue_finished(player):
	dialogue_node.dialogue_started.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(self.hide)
	dialogue_node.dialogue_finished.disconnect(self._on_dialogue_finished)
