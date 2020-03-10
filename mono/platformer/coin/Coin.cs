using Godot;

public class Coin : Area2D
{
    private bool _taken;

    public override void _Ready()
    {
        _taken = false;
    }
    
    public void OnBodyEnter(RigidBody2D body)
    {
        if (!_taken && body is Player)
        {
            _taken = true;
            AnimationPlayer animationPlayer = GetNode("Anim") as AnimationPlayer;
            animationPlayer.Play("taken");
        }
    }
}
