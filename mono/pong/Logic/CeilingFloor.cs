using Godot;

public partial class CeilingFloor : Area2D
{
	public void OnAreaEntered(Area2D area)
	{
		if (area is Ball ball)
		{
			ball.direction = new Vector2(ball.direction.X, -ball.direction.Y);
		}
	}
}
