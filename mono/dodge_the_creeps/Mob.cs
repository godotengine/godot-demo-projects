using Godot;
using System;

public class Mob : RigidBody2D
{
    [Export]
    public int minSpeed; // Minimum speed range.

    [Export]
    public int maxSpeed; // Maximum speed range.

    private String[] _mobTypes = { "walk", "swim", "fly" };

    // C# doesn't have GDScript's random methods, so we use System.Random insetad.
    private static Random _random = new Random();

    public override void _Ready()
    {
        GetNode<AnimatedSprite>("AnimatedSprite").Animation = _mobTypes[_random.Next(0, _mobTypes.Length)];
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
