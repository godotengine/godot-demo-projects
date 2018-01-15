using Godot;
using System;

public class CeilingFloor : Area2D
{
    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            ball.direction.y *= -1;
        }
    }
}
