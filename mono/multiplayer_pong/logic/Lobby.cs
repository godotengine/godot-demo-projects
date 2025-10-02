using Godot;
using System;
using Godot.Collections;

public partial class Lobby : Control
{
    private const int DefaultPort = 8910; // An arbitrary number.
    private const int MaxNumberOfPeers = 1; // How many people we want to have in a game

    private LineEdit _address;
    private Button _hostButton;
    private Button _joinButton;
    private Label _statusOk;
    private Label _statusFail;
    private ENetMultiplayerPeer _peer;

    public override void _Ready()
    {
        // Get nodes - the generic is a class, argument is node path.
        _address = GetNode<LineEdit>("Address");
        _hostButton = GetNode<Button>("HostButton");
        _joinButton = GetNode<Button>("JoinButton");
        _statusOk = GetNode<Label>("StatusOk");
        _statusFail = GetNode<Label>("StatusFail");

        // Connect all callbacks related to networking.
        // Note: Use snake_case when talking to engine API.
        GetTree().GetMultiplayer().Connect("peer_connected", new Callable(this, nameof(PlayerConnected)));
        GetTree().GetMultiplayer().Connect("peer_disconnected", new Callable(this, nameof(PlayerDisconnected)));
        GetTree().GetMultiplayer().Connect("connected_to_server", new Callable(this, nameof(ConnectedOk)));
        GetTree().GetMultiplayer().Connect("connection_failed", new Callable(this, nameof(ConnectedFail)));
        GetTree().GetMultiplayer().Connect("server_disconnected", new Callable(this, nameof(ServerDisconnected)));
    }

    // Network callbacks from SceneTree

    // Callback from SceneTree.
    private void PlayerConnected(int id)
    {
        // Someone connected, start the game!
        var pong = ResourceLoader.Load<PackedScene>("res://pong.tscn").Instantiate();

        // Connect deferred so we can safely erase it from the callback.
        pong.Connect("GameFinished", new Callable(this, nameof(EndGame)), (int) ConnectFlags.Deferred);

        GetTree().Root.AddChild(pong);
        Hide();
    }

    private void PlayerDisconnected(int id)
    {
        EndGame(GetTree().GetMultiplayer().IsServer() ? "Client disconnected" : "Server disconnected");
    }

    // Callback from SceneTree, only for clients (not server).
    private void ConnectedOk()
    {
        // This function is not needed for this project.
    }

    // Callback from SceneTree, only for clients (not server).
    private void ConnectedFail()
    {
        SetStatus("Couldn't connect", false);

        GetTree().GetMultiplayer().MultiplayerPeer = null; // Remove peer.
        _hostButton.Disabled = false;
        _joinButton.Disabled = false;
    }

    private void ServerDisconnected()
    {
        EndGame("Server disconnected");
    }

    // Game creation functions

    private void EndGame(string withError = "")
    {
        if (HasNode("/root/Pong"))
        {
            // Erase immediately, otherwise network might show
            // errors (this is why we connected deferred above).
            GetNode("/root/Pong").Free();
            Show();
        }

        GetTree().GetMultiplayer().MultiplayerPeer = null; // Remove peer.
        _hostButton.Disabled = false;
        _joinButton.Disabled = false;

        SetStatus(withError, false);
    }

    private void SetStatus(string text, bool isOk)
    {
        // Simple way to show status.
        if (isOk)
        {
            _statusOk.Text = text;
            _statusFail.Text = "";
        }
        else
        {
            _statusOk.Text = "";
            _statusFail.Text = text;
        }
    }

    private void OnHostPressed()
    {
        _peer = new ENetMultiplayerPeer();
        Error err = _peer.CreateServer(DefaultPort, MaxNumberOfPeers);
        if (err != Error.Ok)
        {
            // Is another server running?
            SetStatus("Can't host, address in use.", false);
            return;
        }

        _peer.Host.Compress(ENetConnection.CompressionMode.RangeCoder);

        GetTree().GetMultiplayer().MultiplayerPeer = _peer;
        _hostButton.Disabled = true;
        _joinButton.Disabled = true;
        SetStatus("Waiting for player...", true);
    }

    private void OnJoinPressed()
    {
        string ip = _address.Text;
        if (!ip.IsValidIPAddress())
        {
            SetStatus("IP address is invalid", false);
            return;
        }

        _peer = new ENetMultiplayerPeer();
        _peer.CreateClient(ip, DefaultPort);
        _peer.Host.Compress(ENetConnection.CompressionMode.RangeCoder);

        GetTree().GetMultiplayer().MultiplayerPeer = _peer;
        SetStatus("Connecting...", true);
    }
}
