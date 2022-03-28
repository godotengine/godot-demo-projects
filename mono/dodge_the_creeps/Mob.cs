using Godot;

public partial class Mob : RigidDynamicBody2D
{
    public override void _Ready()
    {
        var animSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        animSprite.Playing = true;
        string[] mobTypes = animSprite.Frames.GetAnimationNames();
        animSprite.Animation = mobTypes[GD.Randi() % mobTypes.Length];
    }

    public void OnVisibilityScreenExited()
    {
        QueueFree();
    }
}
