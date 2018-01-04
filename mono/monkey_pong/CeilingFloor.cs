using Godot;
using System;

public class CeilingFloor : Area2D
{
    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            ball.direction += new Vector2(ball.direction.x, -ball.direction.y);
        }
    }
}
