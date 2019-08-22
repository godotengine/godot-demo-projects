extends Control

onready var _client = get_node("Client")
onready var _log_dest = get_node("Panel/VBoxContainer/RichTextLabel")
onready var _line_edit = get_node("Panel/VBoxContainer/Send/LineEdit")
onready var _host = get_node("Panel/VBoxContainer/Connect/Host")
onready var _multiplayer = get_node("Panel/VBoxContainer/Settings/Multiplayer")
onready var _write_mode = get_node("Panel/VBoxContainer/Settings/Mode")
onready var _destination = get_node("Panel/VBoxContainer/Settings/Destination")

func _ready():
	_write_mode.clear()
	_write_mode.add_item("BINARY")
	_write_mode.set_item_metadata(0, WebSocketPeer.WRITE_MODE_BINARY)
	_write_mode.add_item("TEXT")
	_write_mode.set_item_metadata(1, WebSocketPeer.WRITE_MODE_TEXT)

	_destination.add_item("Broadcast")
	_destination.set_item_metadata(0, 0)
	_destination.add_item("Last connected")
	_destination.set_item_metadata(1, 1)
	_destination.add_item("All But last connected")
	_destination.set_item_metadata(2, -1)
	_destination.select(0)

func _on_Mode_item_selected( ID ):
	_client.set_write_mode(_write_mode.get_selected_metadata())

func _on_Send_pressed():
	if _line_edit.text == "":
		return

	var dest = _destination.get_selected_metadata()
	if dest > 0:
		dest = _client.last_connected_client
	elif dest < 0:
		dest = -_client.last_connected_client

	Utils._log(_log_dest, "Sending data %s to %s" % [_line_edit.text, dest])
	_client.send_data(_line_edit.text, dest)
	_line_edit.text = ""

func _on_Connect_toggled( pressed ):
	if pressed:
		var multiplayer = _multiplayer.pressed
		if multiplayer:
			_write_mode.disabled = true
		else:
			_destination.disabled = true
		_multiplayer.disabled = true
		if _host.text != "":
			Utils._log(_log_dest, "Connecting to host: %s" % [_host.text])
			var supported_protocols = PoolStringArray(["my-protocol2", "my-protocol", "binary"])
			_client.connect_to_url(_host.text, supported_protocols, multiplayer)
	else:
		_destination.disabled = false
		_write_mode.disabled = false
		_multiplayer.disabled = false
		_client.disconnect_from_host()
