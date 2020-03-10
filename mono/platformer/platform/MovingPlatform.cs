using Godot;

public class MovingPlatform : Node2D
{
    private const float MomentumConstant1 = 1.0f;
    private const float MomentumConstant2 = 2.0f;
    private const float InitialAccumulatedMomentum = 0.0f;

    [Export]
    private Vector2 _motion;
    [Export]
    private float _cycle;

    private float _accumulatedMomentum;

    public override void _Ready()
    {
        _motion = new Vector2();
        _cycle = 1.0f;
        _accumulatedMomentum = InitialAccumulatedMomentum;
    }

    public override void _PhysicsProcess(float delta)
    {
        _accumulatedMomentum += delta * (MomentumConstant1 / _cycle) * Mathf.Pi * MomentumConstant2;
        _accumulatedMomentum = _accumulatedMomentum % (Mathf.Pi * MomentumConstant2);

        float distance = Mathf.Sin(_accumulatedMomentum);
        Transform2D transform = Transform2D.Identity;

        transform.origin = _motion * distance;

        RigidBody2D platform = GetNode("Platform") as RigidBody2D;
        platform.Transform = transform;
    }
}
