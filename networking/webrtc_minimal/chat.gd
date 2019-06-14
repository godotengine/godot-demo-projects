# An example p2p chat client
extends Node

var peer = WebRTCPeerConnection.new()

# Create negotiated data channel
var channel = peer.create_data_channel("chat", {"negotiated": true, "id": 1})

func _ready():
	# Connect all functions
	peer.connect("ice_candidate_created", self, "_on_ice_candidate")
	peer.connect("session_description_created", self, "_on_session")

	# Register to the local signaling server (see below for the implementation)
	Signaling.register(get_path())

func _on_ice_candidate(mid, index, sdp):
	# Send the ICE candidate to the other peer via signaling server
	Signaling.send_candidate(get_path(), mid, index, sdp)

func _on_session(type, sdp):
	# Send the session to other peer via signaling server
	Signaling.send_session(get_path(), type, sdp)
	# Set generated description as local
	peer.set_local_description(type, sdp)

func _process(delta):
	# Always poll the connection frequently
	peer.poll()
	if channel.get_ready_state() == WebRTCDataChannel.STATE_OPEN:
		while channel.get_available_packet_count() > 0:
			print(get_path(), " received: ", channel.get_packet().get_string_from_utf8())

func send_message(message):
	channel.put_packet(message.to_utf8())