using System;
using Godot;

public partial class Ball : Area2D
{
    private readonly Random _random = new();
    private const int DefaultSpeed = 100;

    public Vector2 Direction { get; set; }

    private Vector2 _initialPos;
    private double _speed = DefaultSpeed;

    public override void _Ready()
    {
        _initialPos = Position;
        Direction = this.NewRandomDirection();
    }

    public override void _Process(double delta)
    {
        _speed += delta * 4;
        Position += (float)(_speed * delta) * Direction;
    }

    public void Reset()
    {
        Direction = this.NewRandomDirection();
        Position = _initialPos;
        _speed = DefaultSpeed;
    }

    public Vector2 NewRandomDirection()
    {
        return new Vector2(this._random.NextSingle() * 2f - 1f, this._random.NextSingle() * 2f - 1f).Normalized();
    }
}
