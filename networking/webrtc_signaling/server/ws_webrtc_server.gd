extends Node

enum Message {
	JOIN,
	ID,
	PEER_CONNECT,
	PEER_DISCONNECT,
	OFFER,
	ANSWER,
	CANDIDATE,
	SEAL,
}

## Unresponsive clients time out after this time (in milliseconds).
const TIMEOUT = 1000

## A sealed room will be closed after this time (in milliseconds).
const SEAL_TIME = 10000

## All alphanumeric characters.
const ALFNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

var _alfnum := ALFNUM.to_ascii_buffer()

var rand: RandomNumberGenerator = RandomNumberGenerator.new()
var lobbies: Dictionary = {}
var tcp_server := TCPServer.new()
var peers: Dictionary = {}

class Peer extends RefCounted:
	var id := -1
	var lobby := ""
	var time := Time.get_ticks_msec()
	var ws := WebSocketPeer.new()


	func _init(peer_id: int, tcp: StreamPeer) -> void:
		id = peer_id
		ws.accept_stream(tcp)


	func is_ws_open() -> bool:
		return ws.get_ready_state() == WebSocketPeer.STATE_OPEN


	func send(type: int, id: int, data: String = "") -> void:
		return ws.send_text(JSON.stringify({
			"type": type,
			"id": id,
			"data": data,
		}))


class Lobby extends RefCounted:
	var peers := {}
	var host := -1
	var sealed := false
	var time := 0  # Value is in milliseconds.
	var mesh := true

	func _init(host_id: int, use_mesh: bool) -> void:
		host = host_id
		mesh = use_mesh

	func join(peer: Peer) -> bool:
		if sealed: return false
		if not peer.is_ws_open(): return false
		peer.send(Message.ID, (1 if peer.id == host else peer.id), "true" if mesh else "")
		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			if not mesh and p.id != host:
				# Only host is visible when using client-server
				continue
			p.send(Message.PEER_CONNECT, peer.id)
			peer.send(Message.PEER_CONNECT, (1 if p.id == host else p.id))
		peers[peer.id] = peer
		return true


	func leave(peer: Peer) -> bool:
		if not peers.has(peer.id):
			return false

		peers.erase(peer.id)
		var close := false
		if peer.id == host:
			# The room host disconnected, will disconnect all peers.
			close = true
		if sealed:
			return close

		# Notify other peers.
		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			if close:
				# Disconnect peers.
				p.ws.close()
			else:
				# Notify disconnection.
				p.send(Message.PEER_DISCONNECT, peer.id)

		return close


	func seal(peer_id: int) -> bool:
		# Only host can seal the room.
		if host != peer_id:
			return false

		sealed = true

		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			p.send(Message.SEAL, 0)

		time = Time.get_ticks_msec()
		peers.clear()

		return true


func _process(_delta: float) -> void:
	poll()


func listen(port: int) -> void:
	if OS.has_feature("web"):
		OS.alert("Cannot create WebSocket servers in Web exports due to browsers' limitations.")
		return
	stop()
	rand.seed = int(Time.get_unix_time_from_system())
	tcp_server.listen(port)


func stop() -> void:
	tcp_server.stop()
	peers.clear()


func poll() -> void:
	if not tcp_server.is_listening():
		return

	if tcp_server.is_connection_available():
		var id := randi() % (1 << 31)
		peers[id] = Peer.new(id, tcp_server.take_connection())

	# Poll peers.
	var to_remove := []
	for p: Peer in peers.values():
		# Peers timeout.
		if p.lobby.is_empty() and Time.get_ticks_msec() - p.time > TIMEOUT:
			p.ws.close()
		p.ws.poll()
		while p.is_ws_open() and p.ws.get_available_packet_count():
			if not _parse_msg(p):
				print("Parse message failed from peer %d" % p.id)
				to_remove.push_back(p.id)
				p.ws.close()
				break
		var state := p.ws.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED:
			print("Peer %d disconnected from lobby: '%s'" % [p.id, p.lobby])
			# Remove from lobby (and lobby itself if host).
			if lobbies.has(p.lobby) and lobbies[p.lobby].leave(p):
				print("Deleted lobby %s" % p.lobby)
				lobbies.erase(p.lobby)
			# Remove from peers
			to_remove.push_back(p.id)

	# Lobby seal.
	for k: String in lobbies:
		if not lobbies[k].sealed:
			continue
		if lobbies[k].time + SEAL_TIME < Time.get_ticks_msec():
			# Close lobby.
			for p: Peer in lobbies[k].peers:
				p.ws.close()
				to_remove.push_back(p.id)

	# Remove stale peers
	for id: int in to_remove:
		peers.erase(id)


func _join_lobby(peer: Peer, lobby: String, mesh: bool) -> bool:
	if lobby.is_empty():
		for _i in 32:
			lobby += char(_alfnum[rand.randi_range(0, ALFNUM.length() - 1)])
		lobbies[lobby] = Lobby.new(peer.id, mesh)
	elif not lobbies.has(lobby):
		return false
	lobbies[lobby].join(peer)
	peer.lobby = lobby
	# Notify peer of its lobby
	peer.send(Message.JOIN, 0, lobby)
	print("Peer %d joined lobby: '%s'" % [peer.id, lobby])
	return true


func _parse_msg(peer: Peer) -> bool:
	var pkt_str: String = peer.ws.get_packet().get_string_from_utf8()
	var parsed: Dictionary = JSON.parse_string(pkt_str)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("type") or not parsed.has("id") or \
		typeof(parsed.get("data")) != TYPE_STRING:
		return false
	if not str(parsed.type).is_valid_int() or not str(parsed.id).is_valid_int():
		return false

	var msg := {
		"type": str(parsed.type).to_int(),
		"id": str(parsed.id).to_int(),
		"data": parsed.data,
	}

	if msg.type == Message.JOIN:
		if peer.lobby:  # Peer must not have joined a lobby already!
			return false

		return _join_lobby(peer, msg.data, msg.id == 0)

	if not lobbies.has(peer.lobby):  # Lobby not found?
		return false

	var lobby: Lobby = lobbies[peer.lobby]

	if msg.type == Message.SEAL:
		# Client is sealing the room.
		return lobby.seal(peer.id)

	var dest_id: int = msg.id
	if dest_id == MultiplayerPeer.TARGET_PEER_SERVER:
		dest_id = lobby.host

	if not peers.has(dest_id):  # Destination ID not connected.
		return false

	if peers[dest_id].lobby != peer.lobby:  # Trying to contact someone not in same lobby.
		return false

	if msg.type in [Message.OFFER, Message.ANSWER, Message.CANDIDATE]:
		var source := MultiplayerPeer.TARGET_PEER_SERVER if peer.id == lobby.host else peer.id
		peers[dest_id].send(msg.type, source, msg.data)
		return true

	return false  # Unknown message.
