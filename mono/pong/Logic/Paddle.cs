using Godot;
using System;

public class Paddle : Area2D
{
    private const int MoveSpeed = 100;

    // All three of these change for each paddle.
    private int _ballDir;
    private string _up;
    private string _down;

    public override void _Ready()
    {
        string name = Name.ToLower();
        _up = name + "_move_up";
        _down = name + "_move_down";
        _ballDir = name == "left" ? 1 : -1;
    }

    public override void _Process(float delta)
    {
        // Move up and down based on input.
        float input = Input.GetActionStrength(_down) - Input.GetActionStrength(_up);
        Vector2 position = Position; // Required so that we can modify position.y.
        position += new Vector2(0, input * MoveSpeed * delta);
        position.y = Mathf.Clamp(position.y, 16, GetViewportRect().Size.y - 16);
        Position = position;
    }

    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            // Assign new direction
            ball.direction = new Vector2(_ballDir, ((float)new Random().NextDouble()) * 2 - 1).Normalized();
        }
    }
}
