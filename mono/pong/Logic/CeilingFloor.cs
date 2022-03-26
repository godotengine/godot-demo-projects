using Godot;

public partial class CeilingFloor : Area2D
{
    [Export]
    private int _bounceDirection = 1;

    public void OnAreaEntered(Area2D area)
    {
        if (area is Ball ball)
        {
            ball.direction = (ball.direction + new Vector2(0, _bounceDirection)).Normalized();
        }
    }
}
