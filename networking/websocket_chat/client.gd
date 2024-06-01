extends Control

@onready var _client: WebSocketClient = $WebSocketClient
@onready var _log_dest: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
@onready var _line_edit: LineEdit = $Panel/VBoxContainer/Send/LineEdit
@onready var _host: LineEdit = $Panel/VBoxContainer/Connect/Host

func info(msg: String) -> void:
	print(msg)
	_log_dest.add_text(str(msg) + "\n")


#region Client signals
func _on_web_socket_client_connection_closed() -> void:
	var ws := _client.get_socket()
	info("Client just disconnected with code: %s, reson: %s" % [ws.get_close_code(), ws.get_close_reason()])


func _on_web_socket_client_connected_to_server() -> void:
	info("Client just connected with protocol: %s" % _client.get_socket().get_selected_protocol())


func _on_web_socket_client_message_received(message: String) -> void:
	info("%s" % message)
#endregion

#region UI signals
func _on_send_pressed() -> void:
	if _line_edit.text.is_empty():
		return

	info("Sending message: %s" % [_line_edit.text])
	_client.send(_line_edit.text)
	_line_edit.text = ""


func _on_connect_toggled(pressed: bool) -> void:
	if not pressed:
		_client.close()
		return

	if _host.text.is_empty():
		return

	info("Connecting to host: %s." % [_host.text])
	var err := _client.connect_to_url(_host.text)
	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
#endregion
