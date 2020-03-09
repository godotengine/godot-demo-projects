using Godot;

public class Cubio : KinematicBody
{
    private const float Gravity = -9.8f;
    private const float MaxSpeed = 5.0f;
    private const float JumpSpeed = 7.0f;
    private const float Acceleration = 2.0f;
    private const float Deacceleration = 4.0f;
    private const float MaxSlopeAngle = 30.0f;
    private static readonly Vector3 InitialPosition = new Vector3(-3, 4, 8);

    private Vector3 _velocity;

    public override void _Ready()
    {
        _velocity = new Vector3();
    }

    public override void _PhysicsProcess(float delta)
    {
        CubioInput cubioInput = ListenToInput();

        if (cubioInput.ResetPosition)
        {
            Translation = InitialPosition;
        }

        Vector3 direction = CalculateDirectionBasedOnInput(cubioInput);

        direction.y = 0;
        direction = direction.Normalized();

        Vector3 newVelocity = calculateNewVelocity(direction, delta);
        _velocity.x = newVelocity.x;
        _velocity.z = newVelocity.z;

        _velocity = MoveAndSlide(_velocity, Vector3.Up);

        if (IsOnFloor() && cubioInput.Jump)
        {
            _velocity.y = JumpSpeed;
        }
    }

    public void OnCubioBodyEntered(PhysicsBody body)
    {
        if (Equals(body))
        {
            CanvasItem winText = GetNode("WinText") as CanvasItem;
            winText.Show();
        }
    }

    private CubioInput ListenToInput()
    {
        bool moveLeft = Input.IsActionPressed("move_left");
        bool moveRight = Input.IsActionPressed("move_right");
        bool moveForward = Input.IsActionPressed("move_forward");
        bool moveBackwards = Input.IsActionPressed("move_backwards");
        bool resetPosition = Input.IsActionPressed("reset_position");
        bool jump = Input.IsActionPressed("jump");

        return new CubioInput(moveLeft, moveRight, moveForward, moveBackwards, resetPosition, jump);
    }

    private Vector3 CalculateDirectionBasedOnInput(CubioInput cubioInput)
    {
        Vector3 direction = new Vector3();
        Spatial camera = GetNode("Target/Camera") as Spatial;
        Transform cameraTransform = camera.GlobalTransform;

        if (cubioInput.MoveForward)
        {
            direction += -cameraTransform.basis[2];
        }
        if (cubioInput.MoveBackWards)
        {
            direction += cameraTransform.basis[2];
        }

        if (cubioInput.MoveLeft)
        {
            direction += -cameraTransform.basis[0];
        }
        if (cubioInput.MoveRight)
        {
            direction += cameraTransform.basis[0];
        }

        return direction;
    }

    private Vector3 calculateNewVelocity(Vector3 direction, float delta)
    {
        _velocity.y += delta * Gravity;
        Vector3 newVelocity = _velocity;

        newVelocity.y = 0;
        Vector3 target = direction * MaxSpeed;
        float acceleration = direction.Dot(newVelocity) > 0 ? Acceleration : Deacceleration;
        newVelocity = newVelocity.LinearInterpolate(target, acceleration * delta);

        return newVelocity;
    }
}
