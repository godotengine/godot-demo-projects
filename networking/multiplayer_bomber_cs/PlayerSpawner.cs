

using Godot;
using Godot.Collections;

public partial class PlayerSpawner : MultiplayerSpawner
{
	public override void _Ready()
	{
		SpawnFunction = new Callable(this, MethodName._spawn_player);
	}

	public CharacterBody2D _spawn_player(Array data)
	{
		var player = GD.Load<PackedScene>("res://player.tscn").Instantiate<Player>();

		player.SyncedPosition = data[0].AsVector2();
		player.Name = data[1].AsString();
		player.SetPlayerName(data[2].AsString());
		return player;
	}
}
