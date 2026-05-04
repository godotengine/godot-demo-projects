using Godot;
using System;
using Array = Godot.Collections.Array;

public partial class BombSpawner : MultiplayerSpawner
{
    public override void _Ready()
    {
        SpawnFunction = new Callable(this, MethodName.SpawnBomb);
    }

    private Area2D SpawnBomb(Array data)
    {
        var bomb = GD.Load<PackedScene>("res://bomb.tscn").Instantiate<Bomb>();

        bomb.Position = data[0].AsVector2();
        bomb.FromPlayer = data[1].AsInt32();
        return bomb;
    }
}
