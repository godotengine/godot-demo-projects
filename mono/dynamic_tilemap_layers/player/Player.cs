using Godot;

public partial class Player : CharacterBody2D
{
    private const float WalkForce = 600;
    private const float WalkMaxSpeed = 200;
    private const float StopForce = 1300;
    private const float JumpSpeed = 200;
    private int _gravity;

    public override void _Ready()
    {
        _gravity = (int)ProjectSettings.GetSetting("physics/2d/default_gravity");
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 velocity = Velocity;

        // Horizontal movement code. First, get the player's input.
        float walk = WalkForce * Input.GetAxis("move_left", "move_right");

        // Slow down the player if they're not trying to move.
        if (Mathf.Abs(walk) < WalkForce * 0.2)
        {
            // The velocity, slowed down a bit, and then reassigned.
            velocity.X = (float)Mathf.MoveToward(velocity.X, 0, StopForce * delta);
        }
        else
        {
            velocity.X += (float)(walk * delta);
        }

        // Clamp to the maximum horizontal movement speed.
        velocity.X = Mathf.Clamp(velocity.X, -WalkMaxSpeed, WalkMaxSpeed);

        // Vertical movement code. Apply gravity.
        velocity.Y += (float)(_gravity * delta);

        // Check for jumping. is_on_floor() must be called after movement code.
        if (IsOnFloor() && Input.IsActionJustPressed("jump"))
        {
            velocity.Y = -JumpSpeed;
        }

        // Move based on the velocity and snap to the ground.
        // TODO: This information should be set to the CharacterBody properties instead of arguments: snap, Vector2.DOWN, Vector2.UP
        // TODO: Rename velocity to linear_velocity in the rest of the script.
        Velocity = velocity;
        MoveAndSlide();
    }
}
