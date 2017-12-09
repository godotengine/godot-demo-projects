using Godot;
using System;

public class Paddle : Area2D
{
    [Export]
    private int ballDir = 1;

    private const int MoveSpeed = 100;

    public override void _Process(float delta)
    {
        String which = GetName();

        // Move up and down based on input
        if (Input.IsActionPressed(which + "_move_up") && Position.y > 0)
        {
            Position -= new Vector2(0, MoveSpeed * delta);
        }
        if (Input.IsActionPressed(which + "_move_down") && Position.y < GetViewportRect().Size.y)
        {
            Position += new Vector2(0, MoveSpeed * delta);
        }
    }

    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            // Assign new direction
            ball.direction = new Vector2(ballDir, (float)new Random().NextDouble() * 2 - 1).Normalized();
        }
    }
}
