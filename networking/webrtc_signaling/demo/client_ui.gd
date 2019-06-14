extends Control

onready var client = $Client

func _ready():
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("connected", self, "_connected")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	client.rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	client.rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	client.rtc_mp.connect("connection_succeeded", self, "_mp_connected")

func _process(delta):
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		_log(client.rtc_mp.get_packet().get_string_from_utf8())

func _connected(id):
	_log("Signaling server connected with ID: %d" % id)

func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [client.code, client.reason])

func _lobby_joined(lobby):
	_log("Joined lobby %s" % lobby)

func _lobby_sealed():
	_log("Lobby has been sealed")

func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())

func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % client.rtc_mp.get_unique_id())

func _mp_peer_connected(id : int):
	_log("Multiplayer peer %d connected" % id)

func _mp_peer_disconnected(id : int):
	_log("Multiplayer peer %d disconnected" % id)

func _log(msg):
	print(msg)
	$vbox/TextEdit.text += str(msg) + "\n"

func ping():
	_log(client.rtc_mp.put_packet("ping".to_utf8()))

func _on_Peers_pressed():
	var d = client.rtc_mp.get_peers()
	_log(d)
	for k in d:
		_log(client.rtc_mp.get_peer(k))

func start():
	client.start($vbox/connect/host.text, $vbox/connect/RoomSecret.text)

func _on_Seal_pressed():
	client.seal_lobby()

func stop():
	client.stop()
