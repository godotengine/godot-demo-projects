extends Control

const _crown = preload("res://img/crown.png")

@onready var _list = $HBoxContainer/VBoxContainer/ItemList
@onready var _action = $HBoxContainer/VBoxContainer/Action

const ACTIONS = ["roll", "pass"]

var _players = []
var _turn = -1

@rpc
func _log(what):
	$HBoxContainer/RichTextLabel.add_text(what + "\n")


@rpc("any_peer")
func set_player_name(p_name):
	if not is_multiplayer_authority():
		return
	var sender = multiplayer.get_remote_sender_id()
	update_player_name.rpc(sender, p_name)


@rpc("call_local")
func update_player_name(player, p_name):
	var pos = _players.find(player)
	if pos != -1:
		_list.set_item_text(pos, p_name)


@rpc("any_peer")
func request_action(action):
	if not is_multiplayer_authority():
		return
	var sender = multiplayer.get_remote_sender_id()
	if _players[_turn] != sender:
		_log.rpc("Someone is trying to cheat! %s" % str(sender))
		return
	if action not in ACTIONS:
		_log.rpc("Invalid action: %s" % action)
		return

	do_action(action)
	next_turn()


func do_action(action):
	var player_name = _list.get_item_text(_turn)
	var val = randi() % 100
	_log.rpc("%s: %ss %d" % [player_name, action, val])


@rpc("call_local")
func set_turn(turn):
	_turn = turn
	if turn >= _players.size():
		return
	for i in range(0, _players.size()):
		if i == turn:
			_list.set_item_icon(i, _crown)
		else:
			_list.set_item_icon(i, null)
	_action.disabled = _players[turn] != multiplayer.get_unique_id()


@rpc("call_local")
func del_player(id):
	var pos = _players.find(id)
	if pos == -1:
		return
	_players.remove_at(pos)
	_list.remove_item(pos)
	if _turn > pos:
		_turn -= 1
	if multiplayer.is_server():
		set_turn.rpc(_turn)


@rpc("call_local")
func add_player(id, pname=""):
	_players.append(id)
	if pname == "":
		_list.add_item("... connecting ...", null, false)
	else:
		_list.add_item(pname, null, false)


func get_player_name(pos):
	if pos < _list.get_item_count():
		return _list.get_item_text(pos)
	else:
		return "Error!"


func next_turn():
	_turn += 1
	if _turn >= _players.size():
		_turn = 0
	set_turn.rpc(_turn)


func start():
	set_turn(0)


func stop():
	_players.clear()
	_list.clear()
	_turn = 0
	_action.disabled = true


func on_peer_add(id):
	if not multiplayer.is_server():
		return
	for i in range(0, _players.size()):
		add_player.rpc_id(id, _players[i], get_player_name(i))
	add_player.rpc(id)
	set_turn.rpc_id(id, _turn)


func on_peer_del(id):
	if not multiplayer.is_server():
		return
	del_player.rpc(id)


func _on_Action_pressed():
	if multiplayer.is_server():
		if _turn != 0:
			return
		do_action("roll")
		next_turn()
	else:
		request_action.rpc_id(1, "roll")
