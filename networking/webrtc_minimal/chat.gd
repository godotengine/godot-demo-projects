extends Node
# An example peer-to-peer chat client.

var peer := WebRTCPeerConnection.new()

# Create negotiated data channel.
var channel = peer.create_data_channel("chat", {"negotiated": true, "id": 1})

func _ready() -> void:
	# Connect all functions.
	peer.ice_candidate_created.connect(_on_ice_candidate)
	peer.session_description_created.connect(_on_session)

	# Register to the local signaling server (see below for the implementation).
	Signaling.register(String(get_path()))


func _on_ice_candidate(media: String, index: int, sdp: String) -> void:
	# Send the ICE candidate to the other peer via the signaling server.
	Signaling.send_candidate(String(get_path()), media, index, sdp)


func _on_session(type: String, sdp: String) -> void:
	# Send the session to other peer via the signaling server.
	Signaling.send_session(String(get_path()), type, sdp)
	# Set generated description as local.
	peer.set_local_description(type, sdp)


func _process(delta: float) -> void:
	# Always poll the connection frequently.
	peer.poll()
	if channel.get_ready_state() == WebRTCDataChannel.STATE_OPEN:
		while channel.get_available_packet_count() > 0:
			print(String(get_path()), " received: ", channel.get_packet().get_string_from_utf8())


func send_message(message: String) -> void:
	channel.put_packet(message.to_utf8_buffer())
