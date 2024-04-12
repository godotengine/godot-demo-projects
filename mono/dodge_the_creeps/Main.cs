using Godot;

public partial class Main : Node
{
#pragma warning disable 649
    // We assign this in the editor, so we don't need the warning about not being assigned.
    [Export]
    public PackedScene MobScene { get; set; }
#pragma warning restore 649

    private int _score;

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
        // Note that for calling Godot-provided methods with strings,
        // we have to use the original Godot snake_case name.
        GetTree().CallGroup("mobs", Node.MethodName.QueueFree);
        _score = 0;

        var player = GetNode<Player>("Player");
        var startPosition = GetNode<Marker2D>("StartPosition");
        player.Start(startPosition.Position);

        GetNode<Timer>("StartTimer").Start();

        var hud = GetNode<HUD>("HUD");
        hud.UpdateScore(_score);
        hud.ShowMessage("Get Ready!");

        GetNode<AudioStreamPlayer>("Music").Play();
    }

    private void OnStartTimerTimeout()
    {
        GetNode<Timer>("MobTimer").Start();
        GetNode<Timer>("ScoreTimer").Start();
    }

    private void OnScoreTimerTimeout()
    {
        _score++;

        GetNode<HUD>("HUD").UpdateScore(_score);
    }

    // We also specified this function name in PascalCase in the editor's connection window.
    private void OnMobTimerTimeout()
    {
        // Note: Normally it is best to use explicit types rather than the `var`
        // keyword. However, var is acceptable to use here because the types are
        // obviously Mob and PathFollow2D, since they appear later on the line.

        if (MobScene is null)
        {
            GD.PrintErr("Mob scene is not set. You need to set it in the inspector.");
            return;
        }
        // Create a new instance of the Mob scene.
        Mob mob = MobScene.Instantiate<Mob>();

        // Choose a random location on Path2D.
        var mobSpawnLocation = GetNode<PathFollow2D>("MobPath/MobSpawnLocation");
        mobSpawnLocation.ProgressRatio = GD.Randf();

        // Set the mob's direction perpendicular to the path direction.
        float direction = mobSpawnLocation.Rotation + Mathf.Pi / 2;

        // Set the mob's position to a random location.
        mob.Position = mobSpawnLocation.Position;

        // Add some randomness to the direction.
        direction += (float)GD.RandRange(-Mathf.Pi / 4, Mathf.Pi / 4);
        mob.Rotation = direction;

        // Choose the velocity for the mob.
        var velocity = new Vector2((float)GD.RandRange(150.0, 250.0), 0);
        mob.LinearVelocity = velocity.Rotated(direction);

        // Spawn the mob by adding it to the Main scene.
        AddChild(mob);
    }
}
