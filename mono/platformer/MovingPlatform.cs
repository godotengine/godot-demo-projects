using Godot;

public class MovingPlatform : Node2D
{
    [Export] Vector2 motion = Vector2.Zero;
    [Export] float cycle = 1.0f;

    float accum;

  // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _PhysicsProcess(float delta)
    {
        accum += delta * (1.0f / cycle) * Mathf.Pi * 2;
        accum %= Mathf.Pi * 2;
        var d = Mathf.Sin(accum);
        var xf = Transform2D.Identity;
        xf[2] = motion * d;
        GetNode<Node2D>("platform").Transform = xf;
    }
}
