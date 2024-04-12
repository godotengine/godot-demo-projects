using Godot;

public partial class Mob : RigidBody2D
{
    public override void _Ready()
    {
        var animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        string[] mobTypes = animatedSprite.SpriteFrames.GetAnimationNames();
        animatedSprite.Play(mobTypes[GD.Randi() % mobTypes.Length]);
    }

    public void OnVisibleOnScreenNotifier2DScreenExited()
    {
        QueueFree();
    }
}
