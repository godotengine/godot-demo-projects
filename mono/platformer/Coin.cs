using Godot;

public class Coin : Area2D
{
    bool taken = false;

    public void _OnCoinBodyEnter(PhysicsBody2D body)
    {
        if (!taken && body is Player)
        {
            GetNode<AnimationPlayer>("anim").Play("taken");
            taken = true;
        }
    }
}
