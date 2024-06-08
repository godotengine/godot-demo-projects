using System;
using Godot;

public partial class Ball : Area2D
{
    private readonly Random _random = new();
    private const int DefaultSpeed = 100;

    public Vector2 direction;

    private Vector2 _initialPos;
    private double _speed = DefaultSpeed;

    public override void _Ready()
    {
        _initialPos = Position;
        direction = this.NewRandomDirection();
    }

    public override void _Process(double delta)
    {
        _speed += delta * 5;
        Position += (float)(_speed * delta) * direction;
    }

    public void Reset()
    {
        direction = this.NewRandomDirection();
        Position = _initialPos;
        _speed = DefaultSpeed;
    }

    public Vector2 NewRandomDirection()
    {
        return new Vector2((float)(this._random.NextDouble() * 2f - 1f), (float)(this._random.NextDouble() * 2f - 1f)).Normalized();
    }
}
