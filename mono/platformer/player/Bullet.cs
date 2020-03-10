using Godot;

public class Bullet : RigidBody2D
{
    public bool Disabled{get; set;}
    private Timer _timer;

    public override void _Ready()
    {
        Disabled = false;
        _timer = GetNode("Timer") as Timer;
        _timer.Start();
    }

    public void Disable()
    {
        if (!Disabled)
        {
            AnimationPlayer animationPlayer = GetNode("Anim") as AnimationPlayer;
            animationPlayer.Play("shutdown");
            Disabled = true;
        }
    }
}
