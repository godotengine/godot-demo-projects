using System.Collections.Generic;
using System.Linq;
using Godot;
using Array = System.Array;

public partial class GameState : Node
{
	// Default game server port. Can be any number between 1024 and 49151.
	// Not on the list of registered or common ports as of May 2024:
	// https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
	private int DEFAULT_PORT = 10567;

	// The maximum number of players.
	private int MAX_PEERS = 12;

	private ENetMultiplayerPeer peer;

	// Our local player's name.
	public string player_name = "The Warrior";

	// Names for remote players in id:name format.
	private Dictionary<long, string> players = new();
	private int[] players_ready = [];

	// Signals to let lobby GUI know what's going on.
	[Signal]
	public delegate void player_list_changedEventHandler();

	[Signal]
	public delegate void connection_failedEventHandler();

	[Signal]
	public delegate void connection_succeededEventHandler();

	[Signal]
	public delegate void game_endedEventHandler();

	[Signal]
	public delegate void game_errorEventHandler(string what);

	// Callback from SceneTree.
	void _player_connected(long id)
	{
		// Registration of a client beings here, tell the connected player that we are here.
		RpcId(id, MethodName.register_player, player_name);
	}


	// Callback from SceneTree.
	void _player_disconnected(long id)
	{
		if (HasNode("/root/World"))
		{
			// Game is in progress.
			if (Multiplayer.IsServer())
			{
				EmitSignal(SignalName.game_error, "Player " + players[id] + " disconnected");
				end_game();
			}
		}
		else
		{
			// Game is not in progress.
			// Unregister this player.
			unregister_player(id);
		}
	}


// Callback from SceneTree, only for clients (not server).
	void _connected_ok()
	{
		// We just connected to a server
		EmitSignal(SignalName.connection_succeeded);
	}


// Callback from SceneTree, only for clients (not server).
	void _server_disconnected()
	{
		EmitSignal(SignalName.game_error, "Server disconnected");
		end_game();
	}


// Callback from SceneTree, only for clients (not server).
	void _connected_fail()
	{
		Multiplayer.SetMultiplayerPeer(null); // Remove peer
		EmitSignal(SignalName.connection_failed);
	}


// Lobby management functions.
	[Rpc(MultiplayerApi.RpcMode.AnyPeer)]
	void register_player(string new_player_name)
	{
		var id = Multiplayer.GetRemoteSenderId();
		players[id] = new_player_name;
		EmitSignal(SignalName.player_list_changed);
	}


	void unregister_player(long id)
	{
		players.Remove(id);
		EmitSignal(SignalName.player_list_changed);
	}

	[Rpc(CallLocal = true)]
	void load_world()
	{
		// Change scene.
		var world = GD.Load<PackedScene>("res://world.tscn").Instantiate<Node2D>();
		GetTree().GetRoot().AddChild(world);
		GetTree().GetRoot().GetNode<Control>("Lobby").Hide();

		// Set up score.
		world.GetNode<Score>("Score").add_player(Multiplayer.GetUniqueId(), player_name);

		foreach (var pn in players)
		{
			world.GetNode<Score>("Score").add_player(pn.Key, pn.Value);
		}

		// Unpause and unleash the game!
		GetTree().Paused = false;
	}


	public void host_game(string new_player_name)
	{
		player_name = new_player_name;
		peer = new ENetMultiplayerPeer();
		peer.CreateServer(DEFAULT_PORT, MAX_PEERS);
		Multiplayer.SetMultiplayerPeer(peer);
	}


	public void join_game(string ip, string new_player_name)
	{
		player_name = new_player_name;
		peer = new ENetMultiplayerPeer();
		peer.CreateClient(ip, DEFAULT_PORT);
		Multiplayer.SetMultiplayerPeer(peer);
	}

	public List<string> get_player_list()
	{
		return players.Values.ToList();
	}


	public void begin_game()
	{
		// TODO server validation    

		Rpc(MethodName.load_world);

		var world = GetTree().GetRoot().GetNode<Node2D>("World");
		var player_scene = GD.Load<PackedScene>("res://player.tscn");

		// Create a dictionary with peer ID. and respective spawn points.
		// TODO: This could be improved by randomizing spawn points for players.
		var spawn_points = new Dictionary<long, int>();
		spawn_points[1] = 0; // Server in spawn point 0.
		var spawn_point_idx = 1;
		foreach (var p in players.Keys)
		{
			spawn_points[p] = spawn_point_idx;
			spawn_point_idx += 1;
		}

		foreach (var p_id in spawn_points.Keys)
		{
			var spawn_pos = world.GetNode<Node2D>("SpawnPoints/" + spawn_points[p_id]).Position;
			var player = player_scene.Instantiate<Player>();
			player.synced_position = spawn_pos;
			player.Name = p_id.ToString();
			world.GetNode("Players").AddChild(player);

			// TODO: why is this logic like this?
			// GDScript: player.set_player_name.rpc(player_name if p_id == multiplayer.get_unique_id() else players[p_id])
			var remotePlayerName = p_id == Multiplayer.GetUniqueId() ? player_name : players[p_id];
			// The RPC must be called after the player is added to the scene tree.

			player.Rpc(Player.MethodName.set_player_name, remotePlayerName);
		}
	}

	void end_game()
	{
		if (HasNode("/root/World"))
		{
			// If the game is in progress, end it.
			GetNode("/root/World").QueueFree();
		}

		EmitSignal(SignalName.game_ended);
		players.Clear();
	}

	public override void _Ready()
	{
		Multiplayer.PeerConnected += _player_connected;
		Multiplayer.PeerDisconnected += _player_disconnected;
		Multiplayer.ConnectedToServer += _connected_ok;
		Multiplayer.ConnectionFailed += _connected_fail;
		Multiplayer.ServerDisconnected += _server_disconnected;
	}

// Returns an unique-looking player color based on the name's hash.
	Color get_player_color(string p_name)
	{
		return Color.FromHsv(Mathf.Wrap(p_name.Hash() * 0.001f, 0.0f, 1.0f), 0.6f, 1.0f);
	}
}
