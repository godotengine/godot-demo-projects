using Godot;
using System;

public partial class Lobby : Control
{
	public override void _Ready()
	{
		// Called every time the node is added to the scene.
		var gamestate = GetNode<GameState>("/root/GameState");
		gamestate.connection_failed += _on_connection_failed;
		gamestate.connection_succeeded += _on_connection_success;
		gamestate.player_list_changed += refresh_lobby;
		gamestate.game_ended += _on_game_ended;
		gamestate.game_error += _on_game_error;

		// Set the player name according to the system username. Fallback to the path.
		var nameLabel = GetNode<LineEdit>("Connect/Name");
		if (OS.HasEnvironment("USERNAME"))
		{
			nameLabel.Text = OS.GetEnvironment("USERNAME");
		}
		else
		{
			var desktop_path = OS.GetSystemDir(OS.SystemDir.Desktop).Replace("\\", "/").Split("/");
			nameLabel.Text = desktop_path[desktop_path.Length - 2];
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

		var player_name = name.Text;
		var gamestate = GetNode<GameState>("/root/GameState");
		gamestate.host_game(player_name);
		GetWindow().Title = ProjectSettings.GetSetting("application/config/name") + ": Server (" + player_name + ")";
		refresh_lobby();
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

		var player_name = name.Text;
		var gamestate = GetNode<GameState>("/root/GameState");
		gamestate.join_game(ip, player_name);
		GetWindow().Title = ProjectSettings.GetSetting("application/config/name") + ": Client (" + player_name + ")";
	}

	void _on_connection_success()
	{
		GetNode<Panel>("Connect").Hide();
		GetNode<Panel>("Players").Show();
	}

	void _on_connection_failed()
	{
		GetNode<Button>("Connect/Host").Disabled = false;
		GetNode<Button>("Connect/Join").Disabled = false;
		GetNode<Label>("Connect/ErrorLabel").SetText("Connection failed.");
	}

	void _on_game_ended()
	{
		Show();
		GetNode<Panel>("Connect").Show();
		GetNode<Panel>("Players").Hide();
		GetNode<Button>("Connect/Host").Disabled = false;
		GetNode<Button>("Connect/Join").Disabled = false;
	}


	void _on_game_error(string errtxt)
	{
		var errDialog = GetNode<AcceptDialog>("ErrorDialog");
		errDialog.DialogText = errtxt;
		errDialog.PopupCentered();
		GetNode<Button>("Connect/Host").Disabled = false;
		GetNode<Button>("Connect/Join").Disabled = false;
	}

	void refresh_lobby()
	{
		var gamestate = GetNode<GameState>("/root/GameState");
		var players = gamestate.get_player_list();
		players.Sort();
		var playerList = GetNode<ItemList>("Players/List");
		playerList.Clear();
		playerList.AddItem(gamestate.player_name + " (you)");
		foreach (var p in players)
		{
			playerList.AddItem(p);
		}

		GetNode<Button>("Players/Start").Disabled = !Multiplayer.IsServer();
	}

	void _on_start_pressed()
	{
		GetNode<GameState>("/root/GameState").begin_game();
	}


	void _on_find_public_ip_pressed()
	{
		OS.ShellOpen("https://icanhazip.com/");
	}
}
