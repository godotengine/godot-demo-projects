using Godot;
using System;

public class Wall : Area2D
{
    public void OnWallAreaEntered(Area2D area)
    {
        if (area is Ball)
        {
            // Oops, ball went out of game place, reset
            Ball ball = (Ball)area;
            ball.Reset();
        }
    }
}
