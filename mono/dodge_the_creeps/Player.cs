using Godot;

public partial class Player : Area2D
{
    [Signal]
    public delegate void HitEventHandler();

    [Export] public int Speed { get; set; } = 400; // How fast the player will move (pixels/sec).

    public Vector2 ScreenSize { get; set; } // Size of the game window.

    public override void _Ready()
    {
        ScreenSize = GetViewportRect().Size;
        Hide();
    }

    public override void _Process(double delta)
    {
        var velocity = Input.GetVector("move_left", "move_right", "move_up", "move_down");

        var animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");

        if (velocity.Length() > 0)
        {
            velocity = velocity.Normalized() * Speed;
            animatedSprite.Play();
        }
        else
        {
            animatedSprite.Stop();
        }

        Position += velocity * (float)delta;
        Position = Position.Clamp(Vector2.Zero, ScreenSize);

        if (velocity.X != 0)
        {
            animatedSprite.Animation = "right";
            // See the note below about boolean assignment.
            animatedSprite.FlipH = velocity.X < 0;
            animatedSprite.FlipV = false;
        }
        else if (velocity.Y != 0)
        {
            animatedSprite.Animation = "up";
            animatedSprite.FlipV = velocity.Y > 0;
        }
    }

    public void Start(Vector2 pos)
    {
        Position = pos;
        Show();
        // Must be deferred as we can't change physics properties on a physics callback.
        GetNode<CollisionShape2D>("CollisionShape2D").SetDeferred(CollisionShape2D.PropertyName.Disabled, false);
    }

    public void OnPlayerBodyEntered(PhysicsBody2D body)
    {
        Hide(); // Player disappears after being hit.
        EmitSignal(SignalName.Hit);
        // Must be deferred as we can't change physics properties on a physics callback.
        GetNode<CollisionShape2D>("CollisionShape2D").SetDeferred("disabled", true);
    }
}
