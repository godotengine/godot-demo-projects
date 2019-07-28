extends Node

onready var _log_dest = get_parent().get_node("Panel/VBoxContainer/RichTextLabel")

var _server = WebSocketServer.new()
var _clients = {}
var _write_mode = WebSocketPeer.WRITE_MODE_BINARY
var _use_multiplayer = true
var last_connected_client = 0

func _init():
	_server.connect("client_connected", self, "_client_connected")
	_server.connect("client_disconnected", self, "_client_disconnected")
	_server.connect("client_close_request", self, "_client_close_request")
	_server.connect("data_received", self, "_client_receive")

	_server.connect("peer_packet", self, "_client_receive")
	_server.connect("peer_connected", self, "_client_connected", ["multiplayer_protocol"])
	_server.connect("peer_disconnected", self, "_client_disconnected")

func _exit_tree():
	_clients.clear()
	_server.stop()

func _process(delta):
	if _server.is_listening():
		_server.poll()

func _client_close_request(id, code, reason):
	print(reason == "Bye bye!")
	Utils._log(_log_dest, "Client %s close code: %d, reason: %s" % [id, code, reason])

func _client_connected(id, protocol):
	_clients[id] = _server.get_peer(id)
	_clients[id].set_write_mode(_write_mode)
	last_connected_client = id
	Utils._log(_log_dest, "%s: Client connected with protocol %s" % [id, protocol])

func _client_disconnected(id, clean = true):
	Utils._log(_log_dest, "Client %s disconnected. Was clean: %s" % [id, clean])
	if _clients.has(id):
		_clients.erase(id)

func _client_receive(id):
	if _use_multiplayer:
		var peer_id = _server.get_packet_peer()
		var packet = _server.get_packet()
		Utils._log(_log_dest, "MPAPI: From %s data: %s" % [peer_id, Utils.decode_data(packet, false)])
	else:
		var packet = _server.get_peer(id).get_packet()
		var is_string = _server.get_peer(id).was_string_packet()
		Utils._log(_log_dest, "Data from %s BINARY: %s: %s" % [id, not is_string, Utils.decode_data(packet, is_string)])

func send_data(data, dest):
	if _use_multiplayer:
		_server.set_target_peer(dest)
		_server.put_packet(Utils.encode_data(data, _write_mode))
	else:
		for id in _clients:
			_server.get_peer(id).put_packet(Utils.encode_data(data, _write_mode))

func listen(port, supported_protocols, multiplayer):
	_use_multiplayer = multiplayer
	if _use_multiplayer:
		set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)
	return _server.listen(port, supported_protocols, multiplayer)

func stop():
	_server.stop()

func set_write_mode(mode):
	_write_mode = mode
	for c in _clients:
		_clients[c].set_write_mode(_write_mode)
