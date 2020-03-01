using Godot;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// Handles Player-specific behavior like moving. We calculate such things with KinematicBody.
/// </summary>
public class PlayerMath25D : KinematicBody
{
    private Node25D _parent;
    public real_t verticalSpeed = 0;
    public bool isometricControls = true;

    public override void _Ready()
    {
        _parent = GetParent<Node25D>();
    }

    public override void _Process(real_t delta)
    {
        if (Input.IsActionPressed("exit"))
        {
            GetTree().Quit();
        }

        if (Input.IsActionJustPressed("view_cube_demo"))
        {
            GetTree().ChangeScene("res://assets/cube/cube.tscn");
            return;
        }

        if (Input.IsActionJustPressed("toggle_isometric_controls"))
        {
            isometricControls = !isometricControls;
        }

        if (Input.IsActionPressed("reset_position"))
        {
            Transform = new Transform(Basis.Identity, Vector3.Up * 10);
            verticalSpeed = 0;
        }
        else
        {
            HorizontalMovement(delta);
            VerticalMovement(delta);
        }
    }

    /// <summary>
    /// Checks WASD and Shift for horizontal movement via MoveAndSlide.
    /// </summary>
    private void HorizontalMovement(real_t delta)
    {
        Vector3 localX = Vector3.Right;
        Vector3 localZ = Vector3.Back;

        if (isometricControls && _parent.Basis25D.x.IsEqualApprox(Basis25D.Isometric.x * Node25D.SCALE))
        {
            localX = new Vector3(0.70710678118f, 0, -0.70710678118f);
            localZ = new Vector3(0.70710678118f, 0, 0.70710678118f);
        }

        // Gather player input and add directional movement to force Vector3 variables
        Vector3 moveDir = Vector3.Zero;
        moveDir += localX * (Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left"));
        moveDir += localZ * (Input.GetActionStrength("move_back") - Input.GetActionStrength("move_forward"));

        moveDir = moveDir.Normalized() * delta * 600;
        if (Input.IsActionPressed("movement_modifier"))
        {
            moveDir /= 2;
        }
        MoveAndSlide(moveDir);
    }

    /// <summary>
    /// Checks Jump and applies gravity and vertical speed via MoveAndCollide.
    /// </summary>
    /// <param name="delta">Time delta since last call</param>
    private void VerticalMovement(real_t delta)
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
