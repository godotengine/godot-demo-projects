extends Node

# The port we will listen to.
const PORT = 9080
# Our WebSocketServer instance.
var _server = WebSocketServer.new()

func _ready():
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	_server.client_connected.connect(self._connected)
	_server.client_disconnected.connect(self._disconnected)
	_server.client_close_request.connect(self._close_request)
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	_server.data_received.connect(self._on_data)
	# Start listening on the given port.
	var err = _server.listen(PORT)
	if err != OK:
		push_error("Unable to start server.")
		set_process(false)


func _connected(id, proto, rname):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print_rich("Client [b]%d[/b] [color=green]connected[/color] with protocol [b]%s[/b] and resource name [b]%s[/b]" % [id, proto, rname])


func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print_rich("Client [b]%d[/b] [color=yellow]disconnecting[/color] with code: [b]%d[/b], reason: [b]%s[/b]" % [id, code, reason])


func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print_rich("Client [b]%d[/b] [color=red]disconnected[/color], clean: [b]%s[/b]" % [id, str(was_clean)])


func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = _server.get_peer(id).get_packet()
	print("Got data from client [b]%d[/b]: [b]%s[/b] ... echoing" % [id, pkt.get_string_from_utf8()])
	_server.get_peer(id).put_packet(pkt)


func _process(_delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	_server.poll()


func _exit_tree():
	_server.stop()
