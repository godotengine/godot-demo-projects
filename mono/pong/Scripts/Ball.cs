using Godot;

public class Ball : Area2D
{
    private const int BallSpeed = 100;

    public Vector2 direction = Vector2.Left;

    private Vector2 _initialPos;

    public void Reset()
    {
        Position = _initialPos;
        direction = Vector2.Left;
    }

    public override void _Ready()
    {
        _initialPos = Position;
    }

    public override void _Process(float delta)
    {
        Position += BallSpeed * delta * direction;
    }
}
