using Godot;
using System;

public class Wall : Area2D
{
    public void OnWallAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            // Oops, ball went out of game place, reset
            ball.Reset();
        }
    }
}
