using Godot;

public class Player : KinematicBody2D
{
    // This demo shows how to build a kinematic controller.

    // Member variables
    public const float GRAVITY = 500.0f; // pixels/second/second

    // Angle in degrees towards either side that the player can consider "floor"
    public const float FLOOR_ANGLE_TOLERANCE = 40f;
    public const float WALK_FORCE = 600f;
    public const float WALK_MIN_SPEED = 10f;
    public const float WALK_MAX_SPEED = 200f;
    public const float STOP_FORCE = 1300f;
    public const float JUMP_SPEED = 200f;
    public const float JUMP_MAX_AIRBORNE_TIME = 0.2f;

    public const float SLIDE_STOP_VELOCITY = 1.0f; // one pixel/second
    public const float SLIDE_STOP_MIN_TRAVEL = 1.0f; // one pixel

    public Vector2 Velocity;
    public float OnAirTime = 100;
    public bool Jumping;

    public bool PrevJumpPressed;

    public override void _PhysicsProcess(float delta)
    {
        // Create forces
        var force = new Vector2(0, GRAVITY);

        var walkLeft = Input.IsActionPressed("move_left");
        var walkRight = Input.IsActionPressed("move_right");
        var jump = Input.IsActionPressed("jump");

        var stop = true;

        if (walkLeft)
        {
            if (Velocity.x <= WALK_MIN_SPEED && Velocity.x > -WALK_MAX_SPEED)
            {
                force.x -= WALK_FORCE;

                stop = false;
            }
        }
        else if (walkRight)
        {
            if (Velocity.x >= -WALK_MIN_SPEED && Velocity.x < WALK_MAX_SPEED)
            {
                force.x += WALK_FORCE;

                stop = false;
            }
        }

        if (stop)
        {
            var vsign = Mathf.Sign(Velocity.x);
            var vlen = Mathf.Abs(Velocity.x);
            vlen -= STOP_FORCE * delta;

            if (vlen < 0)
            {
                vlen = 0;
            }
            Velocity.x = vlen * vsign;
        }

        // Integrate forces to velocity
        Velocity += force * delta;
        // Integrate velocity into motion and move
        Velocity = MoveAndSlide(Velocity, new Vector2(0, -1));

        if (IsOnFloor())
        {
            OnAirTime = 0;
        }

        if (Jumping && Velocity.y > 0)
        {
            // If falling, no longer jumping
            Jumping = false;
        }

        if (OnAirTime < JUMP_MAX_AIRBORNE_TIME && jump && !PrevJumpPressed && !Jumping)
        {
            // Jump must also be allowed to happen if the character left the floor a little bit ago.
            // Makes controls more snappy.
            Velocity.y = -JUMP_SPEED;

            Jumping = true;
        }

        OnAirTime += delta;
        PrevJumpPressed = jump;

        base._PhysicsProcess(delta);
    }
}