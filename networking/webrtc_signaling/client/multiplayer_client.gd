extends "ws_webrtc_client.gd"

var rtc_mp : WebRTCMultiplayer = WebRTCMultiplayer.new()
var sealed = false

func _init():
	connect("connected", self, "connected")
	connect("disconnected", self, "disconnected")

	connect("offer_received", self, "offer_received")
	connect("answer_received", self, "answer_received")
	connect("candidate_received", self, "candidate_received")

	connect("lobby_joined", self, "lobby_joined")
	connect("lobby_sealed", self, "lobby_sealed")
	connect("peer_connected", self, "peer_connected")
	connect("peer_disconnected", self, "peer_disconnected")

func start(url, lobby = ""):
	stop()
	sealed = false
	self.lobby = lobby
	connect_to_url(url)

func stop():
	rtc_mp.close()
	close()

func _create_peer(id : int):
	var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	rtc_mp.add_peer(peer, id)
	if id > rtc_mp.get_unique_id():
		peer.create_offer()
	return peer

func _new_ice_candidate(mid_name : String, index_name : int, sdp_name : String, id : int):
	send_candidate(id, mid_name, index_name, sdp_name)

func _offer_created(type : String, data : String, id : int):
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)

func connected(id : int):
	print("Connected %d" % id)
	rtc_mp.initialize(id, true)

func lobby_joined(lobby : String):
	self.lobby = lobby

func lobby_sealed():
	sealed = true

func disconnected():
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		stop() # Unexpected disconnect

func peer_connected(id : int):
	print("Peer connected %d" % id)
	_create_peer(id)

func peer_disconnected(id : int):
	if rtc_mp.has_peer(id): rtc_mp.remove_peer(id)

func offer_received(id : int, offer : String):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)

func answer_received(id : int, answer : String):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)

func candidate_received(id : int, mid : String, index : int, sdp : String):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)