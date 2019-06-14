# A local signaling server. Add this to autoloads with name "Signaling" (/root/Signaling)
extends Node

# We will store the two peers here
var peers = []

func register(path):
	assert(peers.size() < 2)
	peers.append(path)
	if peers.size() == 2:
		get_node(peers[0]).peer.create_offer()

func _find_other(path):
	# Find the other registered peer.
	for p in peers:
		if p != path:
			return p
	return ""

func send_session(path, type, sdp):
	var other = _find_other(path)
	assert(other != "")
	get_node(other).peer.set_remote_description(type, sdp)

func send_candidate(path, mid, index, sdp):
	var other = _find_other(path)
	assert(other != "")
	get_node(other).peer.add_ice_candidate(mid, index, sdp)