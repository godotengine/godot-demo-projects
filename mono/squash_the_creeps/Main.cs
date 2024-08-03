using Godot;

public partial class Main : Node
{
    [Export]
    public PackedScene MobScene { get; set; }

    public override void _Ready()
    {
        GetNode<Control>("UserInterface/Retry").Hide();
    }

    // We also specified this function name in PascalCase in the editor's connection window
    private void OnMobTimerTimeout()
    {
        // Create a new instance of the Mob scene.
        Mob mob = MobScene.Instantiate<Mob>();

        // Choose a random location on the SpawnPath.
        // We store the reference to the SpawnLocation node.
        PathFollow3D mobSpawnLocation = GetNode<PathFollow3D>("SpawnPath/SpawnLocation");
        // And give it a random offset.
        mobSpawnLocation.ProgressRatio = GD.Randf();

        Vector3 playerPosition = GetNode<Player>("Player").Position;
        mob.Initialize(mobSpawnLocation.Position, playerPosition);

        // Spawn the mob by adding it to the Main scene.
        AddChild(mob);

        // We connect the mob to the score label to update the score upon squashing one.
        mob.Squashed += GetNode<ScoreLabel>("UserInterface/ScoreLabel").OnMobSquashed;
    }

    // We also specified this function name in PascalCase in the editor's connection window
    private void OnPlayerHit()
    {
        GetNode<Timer>("MobTimer").Stop();
        GetNode<Control>("UserInterface/Retry").Show();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("ui_accept") && GetNode<Control>("UserInterface/Retry").Visible)
        {
            // This restarts the current scene.
            GetTree().ReloadCurrentScene();
        }
    }
}
