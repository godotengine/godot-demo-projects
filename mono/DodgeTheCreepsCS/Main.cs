using Godot;
using System;

public class Main : Node
{
    [Export]
    public PackedScene Mob;

    private int _score;

    // We use 'System.Random' as an alternative to GDScript's random methods.
    private Random _random = new Random();

    public override void _Ready()
    {
    }

    // We'll use this later because C# doesn't support GDScript's randi().
    private float RandRange(float min, float max)
    {
        return (float)_random.NextDouble() * (max - min) + min;
    }

    public void GameOver()
    {
        GetNode<Timer>("MobTimer").Stop();
        GetNode<Timer>("ScoreTimer").Stop();

        GetNode<HUD>("HUD").ShowGameOver();

        GetNode<AudioStreamPlayer>("Music").Stop();
        GetNode<AudioStreamPlayer>("DeathSound").Play();
    }

    public void NewGame()
    {
        _score = 0;

        var player = GetNode<Player>("Player");
        var startPosition = GetNode<Position2D>("StartPosition");
        player.Start(startPosition.Position);

        GetNode<Timer>("StartTimer").Start();

        var hud = GetNode<HUD>("HUD");
        hud.UpdateScore(_score);
        hud.ShowMessage("Get Ready!");

        GetNode<AudioStreamPlayer>("Music").Play();
    }

    public void OnStartTimerTimeout()
    {
        GetNode<Timer>("MobTimer").Start();
        GetNode<Timer>("ScoreTimer").Start();
    }

    public void OnScoreTimerTimeout()
    {
        _score++;

        GetNode<HUD>("HUD").UpdateScore(_score);
    }

    public void OnMobTimerTimeout()
    {
        // Choose a random location on Path2D.
        var mobSpawnLocation = GetNode<PathFollow2D>("MobPath/MobSpawnLocation");
        mobSpawnLocation.SetOffset(_random.Next());

        // Create a Mob instance and add it to the scene.
        var mobInstance = (RigidBody2D)Mob.Instance();
        AddChild(mobInstance);

        // Set the mob's direction perpendicular to the path direction.
        float direction = mobSpawnLocation.Rotation + Mathf.Pi / 2;

        // Set the mob's position to a random location.
        mobInstance.Position = mobSpawnLocation.Position;

        // Add some randomness to the direction.
        direction += RandRange(-Mathf.Pi / 4, Mathf.Pi / 4);
        mobInstance.Rotation = direction;

        // Choose the velocity.
        mobInstance.SetLinearVelocity(new Vector2(RandRange(150f, 250f), 0).Rotated(direction));
    }
}
