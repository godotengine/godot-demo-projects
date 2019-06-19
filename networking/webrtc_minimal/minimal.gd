# Main scene
extends Node

# Create the two peers
var p1 = WebRTCPeerConnection.new()
var p2 = WebRTCPeerConnection.new()
var ch1 = p1.create_data_channel("chat", {"id": 1, "negotiated": true})
var ch2 = p2.create_data_channel("chat", {"id": 1, "negotiated": true})

func _ready():
	# Connect P1 session created to itself to set local description
	p1.connect("session_description_created", p1, "set_local_description")
	# Connect P1 session and ICE created to p2 set remote description and candidates
	p1.connect("session_description_created", p2, "set_remote_description")
	p1.connect("ice_candidate_created", p2, "add_ice_candidate")

	# Same for P2
	p2.connect("session_description_created", p2, "set_local_description")
	p2.connect("session_description_created", p1, "set_remote_description")
	p2.connect("ice_candidate_created", p1, "add_ice_candidate")

	# Let P1 create the offer
	p1.create_offer()

	# Wait a second and send message from P1
	yield(get_tree().create_timer(1), "timeout")
	ch1.put_packet("Hi from P1".to_utf8())

	# Wait a second and send message from P2
	yield(get_tree().create_timer(1), "timeout")
	ch2.put_packet("Hi from P2".to_utf8())

func _process(delta):
	p1.poll()
	p2.poll()
	if ch1.get_ready_state() == ch1.STATE_OPEN and ch1.get_available_packet_count() > 0:
		print("P1 received: ", ch1.get_packet().get_string_from_utf8())
	if ch2.get_ready_state() == ch2.STATE_OPEN and ch2.get_available_packet_count() > 0:
		print("P2 received: ", ch2.get_packet().get_string_from_utf8())