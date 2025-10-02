# A local signaling server. Add this to autoloads with name "Signaling" (/root/Signaling)
extends Node

# We will store the two peers here.
var peers: Array[String] = []

func register(path: String) -> void:
	assert(peers.size() < 2)
	peers.push_back(path)
	if peers.size() == 2:
		get_node(peers[0]).peer.create_offer()


func _find_other(path: String) -> String:
	# Find the other registered peer.
	for p in peers:
		if p != path:
			return p

	return ""


func send_session(path: String, type: String, sdp: String) -> void:
	var other := _find_other(path)
	assert(not other.is_empty())
	get_node(other).peer.set_remote_description(type, sdp)


func send_candidate(path: String, media: String, index: int, sdp: String) -> void:
	var other := _find_other(path)
	assert(not other.is_empty())
	get_node(other).peer.add_ice_candidate(media, index, sdp)
