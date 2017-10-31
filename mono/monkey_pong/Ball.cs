using Godot;
using System;

public class Ball : Area2D
{
    private const int BallSpeed = 100;

    private int speed = BallSpeed;
    private Vector2 initialPos;

    public Vector2 direction = new Vector2(-1, 0);

    public void Reset()
    {
        SetPosition(initialPos);
        speed = BallSpeed;
        direction = new Vector2(-1, 0);
    }

    public override void _Ready()
    {
        initialPos = Position;
    }

    public override void _Process(float delta)
    {
        Position += direction * speed * delta;
    }
}
