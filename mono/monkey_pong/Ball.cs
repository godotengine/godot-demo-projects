using Godot;
using System;

public class Ball : Area2D
{
    private const int BALL_SPEED = 100;

    private Vector2 direction = new Vector2(-1, 0);
    private int speed = BALL_SPEED;

    private Vector2 initialPos;

    public void SetDirection(Vector2 newDirection)
    {
        direction = newDirection;
    }
    public Vector2 GetDirection()
    {
        return direction;
    }

    public void Reset()
    {
        SetPosition(initialPos);
        speed = BALL_SPEED;
        direction = new Vector2(-1, 0);
    }

    public override void _Ready()
    {
        initialPos = GetPosition();
    }

    public override void _Process(float delta)
    {
        SetPosition(GetPosition() + direction * speed * delta);
    }
}
