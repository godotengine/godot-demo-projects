extends Control

@onready var client = $Client
@onready var host = $VBoxContainer/Connect/Host
@onready var room = $VBoxContainer/Connect/RoomSecret
@onready var mesh = $VBoxContainer/Connect/Mesh

func _ready():
	client.lobby_joined.connect(self._lobby_joined)
	client.lobby_sealed.connect(self._lobby_sealed)
	client.connected.connect(self._connected)
	client.disconnected.connect(self._disconnected)

	multiplayer.connected_to_server.connect(self._mp_server_connected)
	multiplayer.connection_failed.connect(self._mp_server_disconnect)
	multiplayer.server_disconnected.connect(self._mp_server_disconnect)
	multiplayer.peer_connected.connect(self._mp_peer_connected)
	multiplayer.peer_disconnected.connect(self._mp_peer_disconnected)


@rpc("any_peer", "call_local")
func ping(argument):
	_log("[Multiplayer] Ping from peer %d: arg: %s" % [multiplayer.get_remote_sender_id(), argument])


func _mp_server_connected():
	_log("[Multiplayer] Server connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("[Multiplayer] Peer %d connected" % id)


func _mp_peer_disconnected(id: int):
	_log("[Multiplayer] Peer %d disconnected" % id)


func _connected(id, use_mesh):
	_log("[Signaling] Server connected with ID: %d. Mesh: %s" % [id, use_mesh])


func _disconnected():
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])


func _lobby_joined(lobby):
	_log("[Signaling] Joined lobby %s" % lobby)


func _lobby_sealed():
	_log("[Signaling] Lobby has been sealed")


func _log(msg):
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"


func _on_peers_pressed():
	_log(multiplayer.get_peers())


func _on_ping_pressed():
	ping.rpc(randf())


func _on_seal_pressed():
	client.seal_lobby()


func _on_start_pressed():
	client.start(host.text, room.text, mesh.button_pressed)


func _on_stop_pressed():
	client.stop()
