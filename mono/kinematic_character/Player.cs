using Godot;

public class Player : KinematicBody2D
{
    private const float Gravity = 500;
    private const float FloorAngleTolerance = 40;
    private const float WalkForce = 600;
    private const float WalkMinSpeed = 10;
    private const float WalkMaxSpeed = 200;
    private const float StopForce = 1300;
    private const float JumpSpeed = 200;
    private const float JumpMaxAirborneTime = 0.2f;
    private const float SlideStopVelocity = 1.0f;
    private const float SlideStopMinTravel = 1.0f;

    private Vector2 _velocity;
    private float _onAirTime;
    private bool _jumping;
    private bool _previousJumpPressed;

    public override void _Ready()
    {
        _velocity = new Vector2(0, 0);
        _onAirTime = 100;
        _jumping = false;
        _previousJumpPressed = false;
    }

    public override void _PhysicsProcess(float delta)
    {
        Vector2 force = new Vector2(0, Gravity);
        bool isMoveLeftPressed = Input.IsActionPressed("move_left");
        bool isMoveRightPressed = Input.IsActionPressed("move_right");
        bool isJumpPressed = Input.IsActionPressed("jump");
        bool stop = true;

        if (isMoveLeftPressed)
        {
            if (_velocity.x <= WalkMinSpeed && _velocity.x > -WalkMaxSpeed)
            {
                force.x -= WalkForce;
                stop = false;
            }
        }
        else if (isMoveRightPressed)
        {
            if (_velocity.x >= -WalkMinSpeed && _velocity.x < WalkMaxSpeed)
            {
                force.x += WalkForce;
                stop = false;
            }
        }

        if (stop)
        {
            float velocitySign = Mathf.Sign(_velocity.x);
            float velocityLength = Mathf.Abs(_velocity.x);

            velocityLength -= StopForce * delta;
            if (velocityLength < 0)
            {
                velocityLength = 0;
            }
            _velocity.x = velocityLength * velocitySign;
        }

        _velocity += force * delta;
        _velocity = MoveAndSlide(_velocity, new Vector2(0, -1));

        if (IsOnFloor())
        {
            _onAirTime = 0;
        }
        if (_jumping && _velocity.y > 0)
        {
            _jumping = false;
        }
        if (_onAirTime < JumpMaxAirborneTime && isJumpPressed && !_previousJumpPressed && !_jumping)
        {
            _velocity.y = -JumpSpeed;
            _jumping = true;
        }

        _onAirTime += delta;
        _previousJumpPressed = _jumping;
    }
}
