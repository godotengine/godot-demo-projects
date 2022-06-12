using Godot;
using System;
using Godot.Collections;

public class Lobby : Control
{
    private const int DefaultPort = 8910; // An arbitrary number.
    private const int MaxNumberOfPeers = 1; // How many people we want to have in a game

    private LineEdit _address;
    private Button _hostButton;
    private Button _joinButton;
    private Label _statusOk;
    private Label _statusFail;
    private NetworkedMultiplayerENet _peer;

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
        GetTree().Connect("network_peer_connected", this, nameof(PlayerConnected));
        GetTree().Connect("network_peer_disconnected", this, nameof(PlayerDisconnected));
        GetTree().Connect("connected_to_server", this, nameof(ConnectedOk));
        GetTree().Connect("connection_failed", this, nameof(ConnectedFail));
        GetTree().Connect("server_disconnected", this, nameof(ServerDisconnected));
    }

    // Network callbacks from SceneTree

    // Callback from SceneTree.
    private void PlayerConnected(int id)
    {
        // Someone connected, start the game!
        var pong = ResourceLoader.Load<PackedScene>("res://pong.tscn").Instance();

        // Connect deferred so we can safely erase it from the callback.
        pong.Connect("GameFinished", this, nameof(EndGame), new Godot.Collections.Array(), (int) ConnectFlags.Deferred);

        GetTree().Root.AddChild(pong);
        Hide();
    }

    private void PlayerDisconnected(int id)
    {
        EndGame(GetTree().IsNetworkServer() ? "Client disconnected" : "Server disconnected");
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

        GetTree().NetworkPeer = null; // Remove peer.
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

        GetTree().NetworkPeer = null; // Remove peer.
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
        _peer = new NetworkedMultiplayerENet();
        _peer.CompressionMode = NetworkedMultiplayerENet.CompressionModeEnum.RangeCoder;
        Error err = _peer.CreateServer(DefaultPort, MaxNumberOfPeers);
        if (err != Error.Ok)
        {
            // Is another server running?
            SetStatus("Can't host, address in use.", false);
            return;
        }

        GetTree().NetworkPeer = _peer;
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

        _peer = new NetworkedMultiplayerENet();
        _peer.CompressionMode = NetworkedMultiplayerENet.CompressionModeEnum.RangeCoder;
        _peer.CreateClient(ip, DefaultPort);
        GetTree().NetworkPeer = _peer;
        SetStatus("Connecting...", true);
    }
}
