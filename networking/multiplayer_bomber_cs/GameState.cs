using System.Collections.Generic;
using System.Linq;
using Godot;
using Array = System.Array;

public partial class GameState : Node
{
    // Default game server port. Can be any number between 1024 and 49151.
    // Not on the list of registered or common ports as of May 2024:
    // https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
    private int _defaultPort = 10567;

    // The maximum number of players.
    private int _maxPeers = 12;

    private ENetMultiplayerPeer _peer;

    // Our local player's name.
    public string PlayerName = "The Warrior";

    // Names for remote players in id:name format.
    private Dictionary<long, string> _players = new();
    private int[] _playersReady = [];

    // Signals to let lobby GUI know what's going on.
    [Signal]
    public delegate void PlayerListChangedEventHandler();

    [Signal]
    public delegate void ConnectionFailedEventHandler();

    [Signal]
    public delegate void ConnectionSucceededEventHandler();

    [Signal]
    public delegate void GameEndedEventHandler();

    [Signal]
    public delegate void GameErrorEventHandler(string what);

    // Callback from SceneTree.
    void PlayerConnected(long id)
    {
        // Registration of a client beings here, tell the connected player that we are here.
        RpcId(id, MethodName.RegisterPlayer, PlayerName);
    }


    // Callback from SceneTree.
    void PlayerDisconnected(long id)
    {
        if (HasNode("/root/World"))
        {
            // Game is in progress.
            if (Multiplayer.IsServer())
            {
                EmitSignal(SignalName.GameError, "Player " + _players[id] + " disconnected");
                EndGame();
            }
        }
        else
        {
            // Game is not in progress.
            // Unregister this player.
            UnregisterPlayer(id);
        }
    }


    // Callback from SceneTree, only for clients (not server).
    void ConnectedOk()
    {
        // We just connected to a server
        EmitSignal(SignalName.ConnectionSucceeded);
    }


    // Callback from SceneTree, only for clients (not server).
    void ServerDisconnected()
    {
        EmitSignal(SignalName.GameError, "Server disconnected");
        EndGame();
    }


    // Callback from SceneTree, only for clients (not server).
    void ConnectedFail()
    {
        Multiplayer.SetMultiplayerPeer(null); // Remove peer
        EmitSignal(SignalName.ConnectionFailed);
    }


    // Lobby management functions.
    [Rpc(MultiplayerApi.RpcMode.AnyPeer)]
    void RegisterPlayer(string newPlayerName)
    {
        var id = Multiplayer.GetRemoteSenderId();
        _players[id] = newPlayerName;
        EmitSignal(SignalName.PlayerListChanged);
    }


    void UnregisterPlayer(long id)
    {
        _players.Remove(id);
        EmitSignal(SignalName.PlayerListChanged);
    }

    [Rpc(CallLocal = true)]
    void LoadWorld()
    {
        // Change scene.
        var world = GD.Load<PackedScene>("res://world.tscn").Instantiate<Node2D>();
        GetTree().GetRoot().AddChild(world);
        GetTree().GetRoot().GetNode<Control>("Lobby").Hide();

        // Set up score.
        world.GetNode<Score>("Score").AddPlayer(Multiplayer.GetUniqueId(), PlayerName);

        foreach (var pn in _players)
        {
            world.GetNode<Score>("Score").AddPlayer(pn.Key, pn.Value);
        }
    }


    public void HostGame(string newPlayerName)
    {
        PlayerName = newPlayerName;
        _peer = new ENetMultiplayerPeer();
        _peer.CreateServer(_defaultPort, _maxPeers);
        Multiplayer.SetMultiplayerPeer(_peer);
    }


    public void JoinGame(string ip, string newPlayerName)
    {
        PlayerName = newPlayerName;
        _peer = new ENetMultiplayerPeer();
        _peer.CreateClient(ip, _defaultPort);
        Multiplayer.SetMultiplayerPeer(_peer);
    }

    public List<string> GetPlayerList()
    {
        return _players.Values.ToList();
    }


    public void BeginGame()
    {
        Rpc(MethodName.LoadWorld);

        var world = GetTree().GetRoot().GetNode<Node2D>("World");

        // Create a dictionary with peer ID. and respective spawn points.
        var spawnPoints = new Dictionary<long, int>();
        spawnPoints[1] = 0; // Server in spawn point 0.
        var spawnPointIdx = 1;
        foreach (var p in _players.Keys)
        {
            spawnPoints[p] = spawnPointIdx;
            spawnPointIdx += 1;
        }

        foreach (var pId in spawnPoints.Keys)
        {
            var spawnPos = world.GetNode<Node2D>("SpawnPoints/" + spawnPoints[pId]).Position;

            var playerName = pId == Multiplayer.GetUniqueId() ? PlayerName : _players[pId];

            GetNode<MultiplayerSpawner>("/root/World/Players/PlayerSpawner")
                .Spawn(new Godot.Collections.Array([spawnPos, pId.ToString().ToInt(), playerName]));
        }

        // Unpause and unleash the game!
        GetTree().Paused = false;
    }

    public void EndGame()
    {
        if (HasNode("/root/World"))
        {
            // If the game is in progress, end it.
            GetNode("/root/World").QueueFree();
        }

        EmitSignal(SignalName.GameEnded);
        _players.Clear();
    }

    public override void _Ready()
    {
        Multiplayer.PeerConnected += PlayerConnected;
        Multiplayer.PeerDisconnected += PlayerDisconnected;
        Multiplayer.ConnectedToServer += ConnectedOk;
        Multiplayer.ConnectionFailed += ConnectedFail;
        Multiplayer.ServerDisconnected += ServerDisconnected;
    }

    // Returns an unique-looking player color based on the name's hash.
    public static Color GetPlayerColor(string pName)
    {
        return Color.FromHsv(Mathf.Wrap(pName.Hash() * 0.001f, 0.0f, 1.0f), 0.6f, 1.0f);
    }
}
