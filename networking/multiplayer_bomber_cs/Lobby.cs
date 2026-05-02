using Godot;
using System;

public partial class Lobby : Control
{
    public override void _Ready()
    {
        // Called every time the node is added to the scene.
        var gamestate = GetNode<GameState>("/root/GameState");
        gamestate.ConnectionFailed += OnConnectionFailed;
        gamestate.ConnectionSucceeded += OnConnectionSuccess;
        gamestate.PlayerListChanged += RefreshLobby;
        gamestate.GameEnded += OnGameEnded;
        gamestate.GameError += OnGameError;

        // Set the player name according to the system username. Fallback to the path.
        var nameLabel = GetNode<LineEdit>("Connect/Name");
        if (OS.HasEnvironment("USERNAME"))
        {
            nameLabel.Text = OS.GetEnvironment("USERNAME");
        }
        else
        {
            var desktopPath = OS.GetSystemDir(OS.SystemDir.Desktop).Replace("\\", "/").Split("/");
            nameLabel.Text = desktopPath[desktopPath.Length - 2];
        }
    }

    void _on_host_pressed()
    {
        var name = GetNode<LineEdit>("Connect/Name");
        var errLabel = GetNode<Label>("Connect/ErrorLabel");
        if (name.Text == "")
        {
            errLabel.Text = "Invalid name!";
            return;
        }

        GetNode<Panel>("Connect").Hide();
        GetNode<Panel>("Players").Show();
        errLabel.Text = "";

        var playerName = name.Text;
        var gamestate = GetNode<GameState>("/root/GameState");
        gamestate.HostGame(playerName);
        GetWindow().Title = ProjectSettings.GetSetting("application/config/name") + ": Server (" + playerName + ")";
        RefreshLobby();
    }

    void _on_join_pressed()
    {
        var name = GetNode<LineEdit>("Connect/Name");
        var errLabel = GetNode<Label>("Connect/ErrorLabel");
        if (name.Text == "")
        {
            errLabel.Text = "Invalid name!";
            return;
        }

        var ipInput = GetNode<LineEdit>("Connect/IPAddress");
        var ip = ipInput.Text;
        if (!ip.IsValidIPAddress())
        {
            errLabel.Text = "Invalid IP address!";
            return;
        }


        errLabel.Text = "";
        GetNode<Button>("Connect/Host").Disabled = true;
        GetNode<Button>("Connect/Join").Disabled = true;

        var playerName = name.Text;
        var gamestate = GetNode<GameState>("/root/GameState");
        gamestate.JoinGame(ip, playerName);
        GetWindow().Title = ProjectSettings.GetSetting("application/config/name") + ": Client (" + playerName + ")";
    }

    void OnConnectionSuccess()
    {
        GetNode<Panel>("Connect").Hide();
        GetNode<Panel>("Players").Show();
    }

    void OnConnectionFailed()
    {
        GetNode<Button>("Connect/Host").Disabled = false;
        GetNode<Button>("Connect/Join").Disabled = false;
        GetNode<Label>("Connect/ErrorLabel").SetText("Connection failed.");
    }

    void OnGameEnded()
    {
        Show();
        GetNode<Panel>("Connect").Show();
        GetNode<Panel>("Players").Hide();
        GetNode<Button>("Connect/Host").Disabled = false;
        GetNode<Button>("Connect/Join").Disabled = false;
    }


    void OnGameError(string errtxt)
    {
        var errDialog = GetNode<AcceptDialog>("ErrorDialog");
        errDialog.DialogText = errtxt;
        errDialog.PopupCentered();
        GetNode<Button>("Connect/Host").Disabled = false;
        GetNode<Button>("Connect/Join").Disabled = false;
    }

    void RefreshLobby()
    {
        var gamestate = GetNode<GameState>("/root/GameState");
        var players = gamestate.GetPlayerList();
        players.Sort();
        var playerList = GetNode<ItemList>("Players/List");
        playerList.Clear();
        playerList.AddItem(gamestate.PlayerName + " (you)");
        foreach (var p in players)
        {
            playerList.AddItem(p);
        }

        GetNode<Button>("Players/Start").Disabled = !Multiplayer.IsServer();
    }

    void _on_start_pressed()
    {
        GetNode<GameState>("/root/GameState").BeginGame();
    }


    void _on_find_public_ip_pressed()
    {
        OS.ShellOpen("https://icanhazip.com/");
    }
}
