using Godot;

/// <summary>
/// Handles Player-specific behavior like moving. We calculate such things with CharacterBody3D.
/// </summary>
public partial class PlayerMath25D : CharacterBody3D
{
    private Node25D _parent;
    public float verticalSpeed = 0.0f;
    public bool isometricControls = true;

    public override void _Ready()
    {
        _parent = GetParent<Node25D>();
    }

    public override void _Process(double delta)
    {
        float deltaf = (float) delta;

        if (Input.IsActionPressed("exit"))
        {
            GetTree().Quit();
        }

        if (Input.IsActionJustPressed("view_cube_demo"))
        {
            GetTree().ChangeSceneToFile("res://assets/cube/cube.tscn");
            return;
        }

        if (Input.IsActionJustPressed("toggle_isometric_controls"))
        {
            isometricControls = !isometricControls;
        }

        if (Input.IsActionPressed("reset_position"))
        {
            Transform = new Transform3D(Basis.Identity, Vector3.Up * 10);
            verticalSpeed = 0;
        }
        else
        {
            HorizontalMovement(deltaf);
            VerticalMovement(deltaf);
        }
    }

    /// <summary>
    /// Checks WASD and Shift for horizontal movement via MoveAndSlide.
    /// </summary>
    private void HorizontalMovement(float delta)
    {
        Vector3 localX = Vector3.Right;
        Vector3 localZ = Vector3.Back;

        if (isometricControls && _parent.Basis25D.x.IsEqualApprox(Basis25D.Isometric.x * Node25D.SCALE))
        {
            localX = new Vector3(0.70710678118f, 0, -0.70710678118f);
            localZ = new Vector3(0.70710678118f, 0, 0.70710678118f);
        }

        // Gather player input and add directional movement to a Vector3 variable.
        Vector2 movementVec2 = Input.GetVector("move_left", "move_right", "move_forward", "move_back");
        Vector3 moveDir = localX * movementVec2.X + localZ * movementVec2.Y;

        moveDir = moveDir * delta * 600;
        if (Input.IsActionPressed("movement_modifier"))
        {
            moveDir /= 2;
        }
        Velocity =  moveDir;
        MoveAndSlide();
    }

    /// <summary>
    /// Checks Jump and applies gravity and vertical speed via MoveAndCollide.
    /// </summary>
    /// <param name="delta">Time delta since last call</param>
    private void VerticalMovement(float delta)
    {
        if (Input.IsActionJustPressed("jump"))
        {
            verticalSpeed = 1.25f;
        }
        verticalSpeed -= delta * 5; // Gravity
        var k = MoveAndCollide(Vector3.Up * verticalSpeed);
        if (k != null)
        {
            verticalSpeed = 0;
        }
    }
}
