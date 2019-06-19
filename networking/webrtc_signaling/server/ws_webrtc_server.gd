extends Node

const TIMEOUT = 1000 # Unresponsive clients times out after 1 sec
const SEAL_TIME = 10000 # A sealed room will be closed after this time
const ALFNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

var _alfnum = ALFNUM.to_ascii()

class Peer extends Reference:
	var id = -1
	var lobby = ""
	var time = OS.get_ticks_msec()

	func _init(peer_id):
		id = peer_id

class Lobby extends Reference:
	var peers : Array = []
	var host : int = -1
	var sealed : bool = false
	var time = 0

	func _init(host_id : int):
		host = host_id

	func join(peer_id : int, server : WebSocketServer) -> bool:
		if sealed: return false
		if not server.has_peer(peer_id): return false
		var new_peer : WebSocketPeer = server.get_peer(peer_id)
		new_peer.put_packet(("I: %d\n" % (1 if peer_id == host else peer_id)).to_utf8())
		for p in peers:
			if not server.has_peer(p):
				continue
			server.get_peer(p).put_packet(("N: %d\n" % peer_id).to_utf8())
			new_peer.put_packet(("N: %d\n" % (1 if p == host else p)).to_utf8())
		peers.push_back(peer_id)
		return true

	func leave(peer_id : int, server : WebSocketServer) -> bool:
		if not peers.has(peer_id): return false
		peers.erase(peer_id)
		var close = false
		if peer_id == host:
			# The room host disconnected, will disconnect all peers
			close = true
		if sealed: return close
		# Notify other peers
		for p in peers:
			if not server.has_peer(p): return close
			if close:
				# Disconnect peers
				server.disconnect_peer(p)
			else:
				# Notify disconnection
				server.get_peer(p).put_packet(("D: %d\n" % peer_id).to_utf8())
		return close

	func seal(peer_id : int, server : WebSocketServer) -> bool:
		# Only host can seal the room
		if host != peer_id: return false
		sealed = true
		for p in peers:
			server.get_peer(p).put_packet("S: \n".to_utf8())
		time = OS.get_ticks_msec()
		return true

var rand : RandomNumberGenerator = RandomNumberGenerator.new()
var lobbies : Dictionary = {}
var server : WebSocketServer = WebSocketServer.new()
var peers : Dictionary = {}

func _init():
	server.connect("data_received", self, "_on_data")
	server.connect("client_connected", self, "_peer_connected")
	server.connect("client_disconnected", self, "_peer_disconnected")

func _process(delta):
	poll()

func listen(port : int):
	stop()
	rand.seed = OS.get_unix_time()
	server.listen(port)

func stop():
	server.stop()
	peers.clear()

func poll():
	if not server.is_listening():
		return

	server.poll()

	# Peers timeout
	for p in peers.values():
		if p.lobby == "" and OS.get_ticks_msec() - p.time > TIMEOUT:
			server.disconnect_peer(p.id)
	# Lobby seal
	for k in lobbies:
		if not lobbies[k].sealed:
			continue
		if lobbies[k].time + SEAL_TIME < OS.get_ticks_msec():
			# Close lobby
			for p in lobbies[k].peers:
				server.disconnect_peer(p)

func _peer_connected(id : int, protocol = ""):
	peers[id] = Peer.new(id)

func _peer_disconnected(id : int, was_clean : bool = false):
	var lobby = peers[id].lobby
	print("Peer %d disconnected from lobby: '%s'" % [id, lobby])
	if lobby and lobbies.has(lobby):
		peers[id].lobby = ""
		if lobbies[lobby].leave(id, server):
			# If true, lobby host has disconnected, so delete it.
			print("Deleted lobby %s" % lobby)
			lobbies.erase(lobby)
	peers.erase(id)

func _join_lobby(peer, lobby : String) -> bool:
	if lobby == "":
		for i in range(0, 32):
			lobby += char(_alfnum[rand.randi_range(0, ALFNUM.length()-1)])
		lobbies[lobby] = Lobby.new(peer.id)
	elif not lobbies.has(lobby):
		return false
	lobbies[lobby].join(peer.id, server)
	peer.lobby = lobby
	# Notify peer of its lobby
	server.get_peer(peer.id).put_packet(("J: %s\n" % lobby).to_utf8())
	print("Peer %d joined lobby: '%s'" % [peer.id, lobby])
	return true

func _on_data(id : int):
	if not _parse_msg(id):
		print("Parse message failed from peer %d" % id)
		server.disconnect_peer(id)

func _parse_msg(id : int) -> bool:
	var pkt_str : String = server.get_peer(id).get_packet().get_string_from_utf8()

	var req : PoolStringArray = pkt_str.split('\n', true, 1)
	if req.size() != 2: # Invalid request size
		return false

	var type : String = req[0]
	if type.length() < 3: # Invalid type size
		return false

	if type.begins_with("J: "):
		if peers[id].lobby: # Peer must not have joined a lobby already!
			return false
		return _join_lobby(peers[id], type.substr(3, type.length() - 3))

	if not peers[id].lobby: # Messages across peers are only allowed in same lobby
		return false

	if not lobbies.has(peers[id].lobby): # Lobby not found?
		return false

	var lobby = lobbies[peers[id].lobby]

	if type.begins_with("S: "):
		# Client is sealing the room
		return lobby.seal(id, server)

	var dest_str : String = type.substr(3, type.length() - 3)
	if not dest_str.is_valid_integer(): # Destination id is not an integer
		return false

	var dest_id : int = int(dest_str)
	if dest_id == NetworkedMultiplayerPeer.TARGET_PEER_SERVER:
		dest_id = lobby.host

	if not peers.has(dest_id): # Destination ID not connected
		return false

	if peers[dest_id].lobby != peers[id].lobby: # Trying to contact someone not in same lobby
		return false

	if id == lobby.host:
		id = NetworkedMultiplayerPeer.TARGET_PEER_SERVER

	if type.begins_with("O: "):
		# Client is making an offer
		server.get_peer(dest_id).put_packet(("O: %d\n%s" % [id, req[1]]).to_utf8())
	elif type.begins_with("A: "):
		# Client is making an answer
		server.get_peer(dest_id).put_packet(("A: %d\n%s" % [id, req[1]]).to_utf8())
	elif type.begins_with("C: "):
		# Client is making an answer
		server.get_peer(dest_id).put_packet(("C: %d\n%s" % [id, req[1]]).to_utf8())
	return true