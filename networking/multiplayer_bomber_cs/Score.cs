using Godot;
using System.Collections.Generic;

public partial class Score : HBoxContainer
{
	private class PlayerLabel
	{
		public int Score;
		public string Name;
		public Label Label;
	}

	private Dictionary<long, PlayerLabel> _playerLabels = new();

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
			foreach (var player in _playerLabels.Values)
			{
				if (player.Score > winnerScore)
				{
					winnerScore = player.Score;
					winnerName = player.Name;
				}
			}

			GetNode<Label>("../Winner").Text = "THE WINNER IS:\n" + winnerName;
			GetNode<Label>("../Winner").Show();
		}
	}

	public void IncreaseScore(int forWho)
	{
		var player = _playerLabels[forWho];
		player.Score += 1;
		player.Label.Text = player.Name + "\n" + player.Score;
	}

	public void AddPlayer(long id, string newPlayerName)
	{
		var label = new Label();
		label.HorizontalAlignment = HorizontalAlignment.Center;
		label.Text = newPlayerName + "\n" + 0;
		label.Modulate = GameState.GetPlayerColor(newPlayerName);
		label.SizeFlagsHorizontal = SizeFlags.ExpandFill;
		label.AddThemeFontOverride("font", GD.Load<Font>("res://montserrat.otf"));
		label.AddThemeColorOverride("font_outline_color", Colors.Black);
		label.AddThemeConstantOverride("outline_size", 9);
		label.AddThemeFontSizeOverride("font_size", 18);
		AddChild(label);

		_playerLabels[id] = new PlayerLabel()
		{
			Name = newPlayerName,
			Label = label,
			Score = 0
		};
	}

	public void _on_exit_game_pressed()
	{
		GetNode<GameState>("/root/GameState").EndGame();
	}
}
