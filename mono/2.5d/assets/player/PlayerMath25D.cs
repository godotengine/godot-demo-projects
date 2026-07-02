using Godot;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// Handles Player-specific behavior like moving. We calculate such things with CharacterBody3D.
/// </summary>
public partial class PlayerMath25D : CharacterBody3D
{
	private Node25D _parent;
	public real_t verticalSpeed = 0;
	public bool isometricControls = true;

	public override void _Ready()
	{
		_parent = GetParent<Node25D>();
	}

	public override void _Process(double delta)
	{
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

		if (Input.IsActionPressed("reset_position") || Position.Y <= -100)
		{
			// Reset player position if the player fell down into the void.
			Transform = new Transform3D(Basis.Identity, Vector3.Up * 10);
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
	private void HorizontalMovement(double delta)
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
		Velocity = localX * movementVec2.X + localZ * movementVec2.Y;

		Velocity = Velocity * (float)delta * 2250;
		if (Input.IsActionPressed("movement_modifier"))
		{
			Velocity /= 2;
		}
		MoveAndSlide();
	}

	/// <summary>
	/// Checks Jump and applies gravity and vertical speed via MoveAndCollide.
	/// </summary>
	/// <param name="delta">Time delta since last call</param>
	private void VerticalMovement(double delta)
	{
		if (Input.IsActionJustPressed("jump"))
		{
			verticalSpeed = 0.25f;
		}
		verticalSpeed -= (float)delta; // Gravity
		var k = MoveAndCollide(Vector3.Up * verticalSpeed);
		if (k != null)
		{
			verticalSpeed = 0;
		}
	}
}
