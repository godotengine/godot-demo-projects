
extends Node

#default game port
const DEFAULT_PORT = 10567

#name for my player
var player_name = "The Warrior"

#names for remote players in id:name format
var players = {}

#signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# callback from SceneTree
func _player_connected(id):
	#this is not used, because _connected_ok is called for clients on success and will do the job.
	pass 
	
# callback from SceneTree
func _player_disconnected(id):

	if (get_tree().is_network_server()):
		if (has_node("/root/world")): # game is in progress
			emit_signal("game_error","Player "+players[id]+" disconnected")
			end_game()
		else: #game is not in progress
			#if we are the server, send to the new dude all the already registered playes
			unregister_player(id)
			for p_id in players:
				#erase in the server
				rpc_id( p_id, "unregister_player", id)
			
					
# callback from SceneTree, only for clients (not server)
func _connected_ok():
	#Registration of a client beings here, Tell everyone that we are here
	rpc( "register_player", get_tree().get_network_unique_id(), player_name )
	emit_signal("connection_succeeded")

# callback from SceneTree, only for clients (not server)	
func _server_disconnected():
	emit_signal("game_error","Server disconnected")
	end_game()

# callback from SceneTree, only for clients (not server)	
func _connected_fail():
	get_tree().set_network_peer(null) #remove peer
	emit_signal("connection_failed")	

# lobby management functions
remote func register_player(id, name):
	
	if (get_tree().is_network_server()):
		#if we are the server, let everyone know about the new players
		rpc_id( id, "register_player", 1, player_name ) # send myself to new dude
		for p_id in players: #then, for each remoe player
			rpc_id( id, "register_player", p_id, players[p_id] ) # send player to new dude
			rpc_id( p_id, "register_player", id, name ) # send new dude to player
			
	players[id]=name
					
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
#change scene	
	var world = load("res://world.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("lobby").hide()
	
	var player_scene = load("res://player.tscn")
	
	for p in spawn_points:	
		var spawn_pos = world.get_node("spawn_points/"+str(spawn_points[p])).get_pos()	
		var player = player_scene.instance()
			
		player.set_name( str(p) ) #use unique ID as node name
		player.set_pos(spawn_pos)
		
		
		if (p == get_tree().get_network_unique_id() ):
			# if node for this peer id, set master
			player.set_network_mode( NETWORK_MODE_MASTER )
			player.set_player_name( player_name )
		else:
			# otherwise set slave
			player.set_network_mode( NETWORK_MODE_SLAVE )
			player.set_player_name( players[p] )

		world.get_node("players").add_child(player)
		
	#set up score
	world.get_node("score").add_player(get_tree().get_network_unique_id(),player_name)
	for pn in players:
		world.get_node("score").add_player(pn,players[pn])
	
	if (not get_tree().is_network_server()):
		rpc("ready_to_start", get_tree().get_network_unique_id() )
	elif players.size()==0:
		post_start_game()
	
	
remote func post_start_game():
	get_tree().set_pause(false) #unpause and unleash the game!
	
var players_ready = []

remote func ready_to_start(id):
	
	assert( get_tree().is_network_server() )
	
	if (not id in players_ready):
		players_ready.append(id)
		
	if (players_ready.size() == players.size()):
		for p in players:
			rpc( "post_start_game" )
	
		post_start_game()
		
func host_game( name ):
	player_name=name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT,4)
	get_tree().set_network_peer(host)
	
func join_game(ip, name):
	player_name=name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip,DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert ( get_tree().is_network_server() )
	
	#create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points={}
	spawn_points[1]=0 #server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p]=spawn_point_idx
		spawn_point_idx+=1
	#call to pre-start game with the spawn points
	for p in players:
		rpc( "pre_start_game", spawn_points )
		
	pre_start_game( spawn_points )

func end_game():
	if (has_node("/root/world")): # game is in progress
		#end it
		get_node("/root/world").queue_free()
		
	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer( null ) #end networking

func _ready():
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_ok")
	get_tree().connect("connection_failed",self,"_connected_fail")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	


