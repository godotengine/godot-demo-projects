using Godot;
using System;
using Array = Godot.Collections.Array;

public partial class BombSpawner : MultiplayerSpawner
{
    public override void _Ready()
    {
        SpawnFunction = new Callable(this, MethodName._spawn_bomb);
    }

    public Area2D _spawn_bomb(Array data)
    {
        // TODO: Validation
        var bomb = GD.Load<PackedScene>("res://bomb.tscn").Instantiate<Bomb>();

        bomb.Position = data[0].AsVector2();
        bomb.from_player = data[1].AsInt32();
        return bomb;
    }
}
