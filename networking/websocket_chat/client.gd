extends Control

@onready var _client: WebSocketClient = $WebSocketClient
@onready var _log_dest = $Panel/VBoxContainer/RichTextLabel
@onready var _line_edit = $Panel/VBoxContainer/Send/LineEdit
@onready var _host = $Panel/VBoxContainer/Connect/Host

func info(msg):
	print(msg)
	_log_dest.add_text(str(msg) + "\n")


# Client signals
func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	info("Client just disconnected with code: %s, reson: %s" % [ws.get_close_code(), ws.get_close_reason()])


func _on_web_socket_client_connected_to_server():
	info("Client just connected with protocol: %s" % _client.get_socket().get_selected_protocol())


func _on_web_socket_client_message_received(message):
	info("%s" % message)


# UI signals.
func _on_send_pressed():
	if _line_edit.text == "":
		return

	info("Sending message: %s" % [_line_edit.text])
	_client.send(_line_edit.text)
	_line_edit.text = ""


func _on_connect_toggled(pressed):
	if not pressed:
		_client.close()
		return
	if _host.text == "":
		return
	info("Connecting to host: %s." % [_host.text])
	var err = _client.connect_to_url(_host.text)
	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
