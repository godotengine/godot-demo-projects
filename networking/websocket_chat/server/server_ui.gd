extends Control

onready var _server = get_node("Server")
onready var _port = get_node("Panel/VBoxContainer/HBoxContainer/Port")
onready var _line_edit = get_node("Panel/VBoxContainer/HBoxContainer3/LineEdit")
onready var _write_mode = get_node("Panel/VBoxContainer/HBoxContainer2/WriteMode")
onready var _log_dest = get_node("Panel/VBoxContainer/RichTextLabel")
onready var _multiplayer = get_node("Panel/VBoxContainer/HBoxContainer2/MPAPI")
onready var _destination = get_node("Panel/VBoxContainer/HBoxContainer2/Destination")

func _ready():
	_write_mode.clear()
	_write_mode.add_item("BINARY")
	_write_mode.set_item_metadata(0, WebSocketPeer.WRITE_MODE_BINARY)
	_write_mode.add_item("TEXT")
	_write_mode.set_item_metadata(1, WebSocketPeer.WRITE_MODE_TEXT)
	_write_mode.select(0)

	_destination.add_item("Broadcast")
	_destination.set_item_metadata(0, 0)
	_destination.add_item("Last connected")
	_destination.set_item_metadata(1, 1)
	_destination.add_item("All But last connected")
	_destination.set_item_metadata(2, -1)
	_destination.select(0)

func _on_Listen_toggled( pressed ):
	if pressed:
		var use_multiplayer = _multiplayer.pressed
		_multiplayer.disabled = true
		var supported_protocols = PoolStringArray(["my-protocol", "binary"])
		var port = int(_port.value)
		if use_multiplayer:
			_write_mode.disabled = true
			_write_mode.select(0)
		else:
			_destination.disabled = true
			_destination.select(0)
		if _server.listen(port, supported_protocols, use_multiplayer) == OK:
			Utils._log(_log_dest, "Listing on port %s" % port)
			if not use_multiplayer:
				Utils._log(_log_dest, "Supported protocols: %s" % supported_protocols)
		else:
			Utils._log(_log_dest, "Error listening on port %s" % port)
	else:
		_server.stop()
		_multiplayer.disabled = false
		_write_mode.disabled = false
		_destination.disabled = false
		Utils._log(_log_dest, "Server stopped")

func _on_Send_pressed():
	if _line_edit.text == "":
		return

	var dest = _destination.get_selected_metadata()
	if dest > 0:
		dest = _server.last_connected_client
	elif dest < 0:
		dest = -_server.last_connected_client

	Utils._log(_log_dest, "Sending data %s to %s" % [_line_edit.text, dest])
	_server.send_data(_line_edit.text, dest)
	_line_edit.text = ""

func _on_WriteMode_item_selected( ID ):
	_server.set_write_mode(_write_mode.get_selected_metadata())
