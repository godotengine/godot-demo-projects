extends Control

@onready var _server: WebSocketServer = $WebSocketServer
@onready var _log_dest: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
@onready var _line_edit: LineEdit = $Panel/VBoxContainer/Send/LineEdit
@onready var _listen_port: SpinBox = $Panel/VBoxContainer/Connect/Port

func info(msg: String) -> void:
	print(msg)
	_log_dest.add_text(str(msg) + "\n")


#region Server signals
func _on_web_socket_server_client_connected(peer_id: int) -> void:
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client connected: %d. Protocol: %s" % [peer_id, peer.get_selected_protocol()])
	_server.send(-peer_id, "[%d] connected" % peer_id)


func _on_web_socket_server_client_disconnected(peer_id: int) -> void:
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client disconnected: %d. Code: %d, Reason: %s" % [peer_id, peer.get_close_code(), peer.get_close_reason()])
	_server.send(-peer_id, "[%d] disconnected" % peer_id)


func _on_web_socket_server_message_received(peer_id: int, message: String) -> void:
	info("Server received data from peer %d: %s" % [peer_id, message])
	_server.send(-peer_id, "[%d] Says: %s" % [peer_id, message])
#endregion

#region UI signals
func _on_send_pressed() -> void:
	if _line_edit.text == "":
		return

	info("Sending message: %s" % [_line_edit.text])
	_server.send(0, "Server says: %s" % _line_edit.text)
	_line_edit.text = ""


func _on_listen_toggled(pressed: bool) -> void:
	if not pressed:
		_server.stop()
		info("Server stopped")
		return

	var port := int(_listen_port.value)
	var err := _server.listen(port)

	if err != OK:
		info("Error listing on port %s" % port)
		return
	info("Listing on port %s, supported protocols: %s" % [port, _server.supported_protocols])
#endregion
