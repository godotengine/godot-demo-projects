using Godot;

public partial class CeilingFloor : Area2D
{
	public void OnAreaEntered(Area2D area)
	{
		if (area is Ball ball)
		{
			ball.Direction = new Vector2(ball.Direction.X, -ball.Direction.Y);
		}
	}
}
