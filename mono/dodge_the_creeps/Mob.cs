using Godot;

public partial class Mob : RigidBody2D
{
    public override void _Ready()
    {
        var animSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        animSprite.Play();
        string[] mobTypes = animSprite.SpriteFrames.GetAnimationNames();
        animSprite.Animation = mobTypes[GD.Randi() % mobTypes.Length];
    }

    public void OnVisibilityScreenExited()
    {
        QueueFree();
    }
}
