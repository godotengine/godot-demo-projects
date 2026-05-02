using Godot;
using System;
using System.Collections.Generic;

public partial class Score : HBoxContainer
{
	private class PlayerLabel
	{
		public int Score;
		public string Name;
		public Label Label;
	}
	private Dictionary<int, PlayerLabel> playerLabels = new();
	
	public override void _Ready()
	{
		GetNode<Label>("../Winner").Hide();
	}

	public override void _Process(double delta)
	{
		var rocksLeft = GetNode("../Rocks").GetChildCount();
		if (rocksLeft == 0)
		{
			var winnerName = "";
			var winnerScore = 0;
			foreach (var player in playerLabels.Values)
			{
				if (player.Score > winnerScore)
				{
					winnerScore = player.Score;
					winnerName = player.Name;
				}
			}
			
			GetNode<Label>("../Winner").SetText("THE WINNER IS:\n" + winnerName);
			GetNode<Label>("../Winner").Show();
		}
	}

	void increase_score(int for_who)
	{
		var player = playerLabels[for_who];
		player.Score += 1;
		player.Label.SetText(player.Name + "\n" + player.Score);
	}

	void add_player(int id, string new_player_name)
	{
		var label = new Label();
		label.HorizontalAlignment = HorizontalAlignment.Center;
		label.Text = new_player_name + "\n" + 0;
		label.Modulate = GetNode("/root/gamestate").Call("get_player_color", new_player_name).AsColor();
		label.SizeFlagsHorizontal = SizeFlags.ExpandFill;
		label.AddThemeFontOverride("font", GD.Load<Font>("res://montserrat.otf"));
		label.AddThemeColorOverride("font_outline_color", Colors.Black);
		label.AddThemeConstantOverride("outline_size", 9);
		label.AddThemeFontSizeOverride("font_size", 18);
		AddChild(label);
		
		playerLabels[id] = new PlayerLabel()
		{
			Name = new_player_name,
			Label = label,
			Score = 0
		};
		
	}

	public void _on_exit_game_pressed()
	{
		GetNode("/root/gamestate").Call("end_game");
	}
}
