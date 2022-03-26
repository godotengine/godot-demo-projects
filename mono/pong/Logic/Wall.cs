using Godot;

public partial class Wall : Area2D
{
    public void OnWallAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            // Ball went off the side of the screen, reset it.
            ball.Reset();
        }
    }
}
