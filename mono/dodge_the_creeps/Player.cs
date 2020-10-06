using Godot;

public class Player : Area2D
{
    [Signal]
    public delegate void Hit();

    // These only need to be accessed in this script, so we can make them private.
    // Private variables in C# in Godot have their name starting with an
    // underscore and also have the "private" keyword instead of "public".
    [Export]
    private int _speed = 400; // How fast the player will move (pixels/sec).

    private Vector2 _screenSize; // Size of the game window.

    public override void _Ready()
    {
        _screenSize = GetViewportRect().Size;
        Hide();
    }

    public override void _Process(float delta)
    {
        Vector2 velocity; // The player's movement vector.
        velocity.x = Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left");
        velocity.y = Input.GetActionStrength("move_down") - Input.GetActionStrength("move_up");

        var animatedSprite = GetNode<AnimatedSprite>("AnimatedSprite");

        if (velocity.Length() > 0)
        {
            velocity = velocity.Normalized() * _speed;
            animatedSprite.Play();
        }
        else
        {
            animatedSprite.Stop();
        }

        Position += velocity * delta;
        Position = new Vector2(
            x: Mathf.Clamp(Position.x, 0, _screenSize.x),
            y: Mathf.Clamp(Position.y, 0, _screenSize.y)
        );

        if (velocity.x != 0)
        {
            animatedSprite.Animation = "right";
            // See the note below about boolean assignment.
            animatedSprite.FlipH = velocity.x < 0;
            animatedSprite.FlipV = false;
        }
        else if (velocity.y != 0)
        {
            animatedSprite.Animation = "up";
            animatedSprite.FlipV = velocity.y > 0;
        }
    }

    public void Start(Vector2 pos)
    {
        Position = pos;
        Show();
        // Must be deferred as we can't change physics properties on a physics callback.
        GetNode<CollisionShape2D>("CollisionShape2D").SetDeferred("disabled", false);
    }

    public void OnPlayerBodyEntered(PhysicsBody2D body)
    {
        Hide(); // Player disappears after being hit.
        EmitSignal(nameof(Hit));
        // Must be deferred as we can't change physics properties on a physics callback.
        GetNode<CollisionShape2D>("CollisionShape2D").SetDeferred("disabled", true);
    }
}
