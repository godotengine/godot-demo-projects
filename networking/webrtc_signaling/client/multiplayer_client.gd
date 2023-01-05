extends "ws_webrtc_client.gd"

var rtc_mp: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var sealed := false

func _init():
	connected.connect(self._connected)
	disconnected.connect(self._disconnected)

	offer_received.connect(self._offer_received)
	answer_received.connect(self._answer_received)
	candidate_received.connect(self._candidate_received)

	lobby_joined.connect(self._lobby_joined)
	lobby_sealed.connect(self._lobby_sealed)
	peer_connected.connect(self._peer_connected)
	peer_disconnected.connect(self._peer_disconnected)


func start(url, lobby = "", mesh:=true):
	stop()
	sealed = false
	self.mesh = mesh
	self.lobby = lobby
	connect_to_url(url)


func stop():
	multiplayer.multiplayer_peer = null
	rtc_mp.close()
	close()


func _create_peer(id):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.session_description_created.connect(self._offer_created.bind(id))
	peer.ice_candidate_created.connect(self._new_ice_candidate.bind(id))
	rtc_mp.add_peer(peer, id)
	if id < rtc_mp.get_unique_id(): # So lobby creator never creates offers.
		peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func _connected(id, use_mesh):
	print("Connected %d, mesh: %s" % [id, use_mesh])
	if use_mesh:
		rtc_mp.create_mesh(id)
	elif id == 1:
		rtc_mp.create_server()
	else:
		rtc_mp.create_client(id)
	multiplayer.multiplayer_peer = rtc_mp


func _lobby_joined(lobby):
	self.lobby = lobby


func _lobby_sealed():
	sealed = true


func _disconnected():
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		stop() # Unexpected disconnect


func _peer_connected(id):
	print("Peer connected %d" % id)
	_create_peer(id)


func _peer_disconnected(id):
	if rtc_mp.has_peer(id): rtc_mp.remove_peer(id)


func _offer_received(id, offer):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


func _answer_received(id, answer):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func _candidate_received(id, mid, index, sdp):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
