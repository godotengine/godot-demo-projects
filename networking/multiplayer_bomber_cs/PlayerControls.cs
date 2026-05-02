using Godot;
using System;

public partial class PlayerControls : Node
{
	private Vector2 _motion = new();

	[Export]
	public Vector2 Motion
	{
		get => _motion;
		set { _motion = value.Clamp(new Vector2(-1, -1), new Vector2(1, 1)); }
	}

	[Export] public bool Bombing;

	public void Update()
	{
		var m = new Vector2();
		if (Input.IsActionPressed("move_left"))
		{
			m += new Vector2(-1, 0);
		}

		if (Input.IsActionPressed("move_right"))
		{
			m += new Vector2(1, 0);
		}

		if (Input.IsActionPressed("move_up"))
		{
			m += new Vector2(0, -1);
		}

		if (Input.IsActionPressed("move_down"))
		{
			m += new Vector2(0, 1);
		}

		Motion = m;
		Bombing = Input.IsActionPressed("set_bomb");
	}
}
