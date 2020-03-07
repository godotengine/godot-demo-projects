using Godot;

public class Cubio : KinematicBody
{

    private const float GRAVITY = -9.8f;
    private const float MAX_SPEED = 5.0f;
    private const float JUMP_SPEED = 7.0f;
    private const float ACCELERATION = 2.0f;
    private const float DEACCELERATION = 4.0f;
    private const float MAX_SLOPE_ANGLE = 30.0f;
    private static readonly Vector3 INITIAL_POSITION = new Vector3(-3, 4, 8);


    private Vector3 velocity;

    public override void _Ready()
    {
        this.velocity = new Vector3();
    }

    public override void _PhysicsProcess(float delta)
    {
        CubioInput cubioInput = ListenToInput();

        if (cubioInput.ResetPosition)
        {
            this.Translation = INITIAL_POSITION;
        }

        Vector3 direction = CalculateDirectionBasedOnInput(cubioInput);

        direction.y = 0;
        direction = direction.Normalized();

        Vector3 newVelocity = calculateNewVelocity(direction, delta);
        this.velocity.x = newVelocity.x;
        this.velocity.z = newVelocity.z;

        this.velocity = MoveAndSlide(this.velocity, Vector3.Up);

        if (IsOnFloor() && cubioInput.Jump)
        {
            this.velocity.y = JUMP_SPEED;
        }
    }

    public void OnCubioBodyEntered(PhysicsBody body)
    {
        if (this.Equals(body))
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
        this.velocity.y += delta * GRAVITY;
        Vector3 newVelocity = this.velocity;

        newVelocity.y = 0;
        Vector3 target = direction * MAX_SPEED;
        float acceleration = direction.Dot(newVelocity) > 0 ? ACCELERATION : DEACCELERATION;
        newVelocity = newVelocity.LinearInterpolate(target, acceleration * delta);

        return newVelocity;
    }

}
