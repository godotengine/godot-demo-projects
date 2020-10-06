using Godot;
using System;

public class Mob : RigidBody2D
{
    [Export]
    public int minSpeed;

    [Export]
    public int maxSpeed;

    public override void _Ready()
    {
        var animSprite = GetNode<AnimatedSprite>("AnimatedSprite");
        animSprite.Playing = true;
        string[] mobTypes = animSprite.Frames.GetAnimationNames();
        animSprite.Animation = mobTypes[GD.Randi() % mobTypes.Length];
    }

    public void OnVisibilityScreenExited()
    {
        QueueFree();
    }

    public void OnStartGame()
    {
        QueueFree();
    }
}
