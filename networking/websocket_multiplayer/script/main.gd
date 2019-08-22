extends Control

const DEF_PORT = 8080
const PROTO_NAME = "ludus"

onready var _host_btn = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Host
onready var _connect_btn = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Connect
onready var _disconnect_btn = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Disconnect
onready var _name_edit = $Panel/VBoxContainer/HBoxContainer/NameEdit
onready var _host_edit = $Panel/VBoxContainer/HBoxContainer2/Hostname
onready var _game = $Panel/VBoxContainer/Game

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	$AcceptDialog.get_label().align = Label.ALIGN_CENTER
	$AcceptDialog.get_label().valign = Label.VALIGN_CENTER

func start_game():
	_host_btn.disabled = true
	_name_edit.editable = false
	_host_edit.editable = false
	_connect_btn.hide()
	_disconnect_btn.show()
	_game.start()

func stop_game():
	_host_btn.disabled = false
	_name_edit.editable = true
	_host_edit.editable = true
	_disconnect_btn.hide()
	_connect_btn.show()
	_game.stop()

func _close_network():
	if get_tree().is_connected("server_disconnected", self, "_close_network"):
		get_tree().disconnect("server_disconnected", self, "_close_network")
	if get_tree().is_connected("connection_failed", self, "_close_network"):
		get_tree().disconnect("connection_failed", self, "_close_network")
	if get_tree().is_connected("connected_to_server", self, "_connected"):
		get_tree().disconnect("connected_to_server", self, "_connected")
	stop_game()
	$AcceptDialog.show_modal()
	$AcceptDialog.get_close_button().grab_focus()
	get_tree().set_network_peer(null)

func _connected():
	_game.rpc("set_player_name", _name_edit.text)

func _peer_connected(id):
	_game.on_peer_add(id)

func _peer_disconnected(id):
	_game.on_peer_del(id)

func _on_Host_pressed():
	var host = WebSocketServer.new()
	host.listen(DEF_PORT, PoolStringArray(["ludus"]), true)
	get_tree().connect("server_disconnected", self, "_close_network")
	get_tree().set_network_peer(host)
	_game.add_player(1, _name_edit.text)
	start_game()

func _on_Disconnect_pressed():
	_close_network()

func _on_Connect_pressed():
	var host = WebSocketClient.new()
	host.connect_to_url("ws://" + _host_edit.text + ":" + str(DEF_PORT), PoolStringArray([PROTO_NAME]), true)
	get_tree().connect("connection_failed", self, "_close_network")
	get_tree().connect("connected_to_server", self, "_connected")
	get_tree().set_network_peer(host)
	start_game()
