using Godot;
using System;

public class CeilingFloor : Area2D
{
    [Export]
    private int yDirection = 1;

    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball)
        {
            Ball ball = (Ball)area;
            ball.SetDirection(ball.GetDirection() + new Vector2(0, yDirection));
        }
    }
}
