extends Control

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")

func _on_host_pressed():
	if (get_node("connect/name").get_text() == ""):
		get_node("connect/error_label").set_text("Invalid name!")
		return

	get_node("connect").hide()
	get_node("players").show()
	get_node("connect/error_label").set_text("")

	var name = get_node("connect/name").get_text()
	gamestate.host_game(name)
	refresh_lobby()

func _on_join_pressed():
	if (get_node("connect/name").get_text() == ""):
		get_node("connect/error_label").set_text("Invalid name!")
		return

	var ip = get_node("connect/ip").get_text()
	if (not ip.is_valid_ip_address()):
		get_node("connect/error_label").set_text("Invalid IPv4 address!")
		return

	get_node("connect/error_label").set_text("")
	get_node("connect/host").set_disabled(true)
	get_node("connect/join").set_disabled(true)

	var name = get_node("connect/name").get_text()
	gamestate.join_game(ip, name)
	# refresh_lobby() gets called by the player_list_changed signal

func _on_connection_success():
	get_node("connect").hide()
	get_node("players").show()

func _on_connection_failed():
	get_node("connect/host").set_disabled(false)
	get_node("connect/join").set_disabled(false)
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/host").set_disabled(false)
	get_node("connect/join").set_disabled(false)

func _on_game_error(errtxt):
	get_node("error").set_text(errtxt)
	get_node("error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("players/list").clear()
	get_node("players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("players/list").add_item(p)

	get_node("players/start").set_disabled(not get_tree().is_network_server())

func _on_start_pressed():
	gamestate.begin_game()
