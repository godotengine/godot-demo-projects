using Godot;

public partial class Ball : Area2D
{
    private const int DefaultSpeed = 100;

    public Vector2 direction = Vector2.Left;

    private Vector2 _initialPos;
    private double _speed = DefaultSpeed;

    public override void _Ready()
    {
        _initialPos = Position;
    }

    public override void _Process(double delta)
    {
        _speed += delta * 2;
        Position += (float)(_speed * delta) * direction;
    }

    public void Reset()
    {
        direction = Vector2.Left;
        Position = _initialPos;
        _speed = DefaultSpeed;
    }
}
