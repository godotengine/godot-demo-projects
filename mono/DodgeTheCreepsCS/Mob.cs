using Godot;
using System;

public class Mob : RigidBody2D
{
    [Export]
    public int MinSpeed; // Minimum speed range.

    [Export]
    public int MaxSpeed; // Maximum speed range.

    private String[] _mobTypes = {"walk", "swim", "fly"};

    // C# doesn't implement GDScript's random methods, so we use 'System.Random'
    // as an alternative.
    static private Random _random = new Random();

    public override void _Ready()
    {
        GetNode<AnimatedSprite>("AnimatedSprite").Animation = _mobTypes[_random.Next(0, _mobTypes.Length)];
    }

    public void OnVisibilityScreenExited()
    {
        QueueFree();
    }

}
