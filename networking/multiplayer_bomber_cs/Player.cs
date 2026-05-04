using Godot;
using System;
using Godot.NativeInterop;
using Array = Godot.Collections.Array;

public partial class Player : CharacterBody2D
{
    // The player's movement speed (in pixels per second).
    private static float _motionSpeed = 90.0f;

    // The delay before which you can place a new bomb (in seconds).
    private static float _bombRate = 0.5f;

    [Export] public Vector2 SyncedPosition = new Vector2();

    [Export] public bool Stunned = false;

    private double _lastBombTime = _bombRate;
    private string _currentAnim = "";


    public override void _Ready()
    {
        this.Stunned = false;
        Console.WriteLine("Pos:" + SyncedPosition);
        Position = SyncedPosition;
        if (Name.ToString().IsValidInt())
        {
            GetNode<MultiplayerSynchronizer>("Inputs/InputsSync").SetMultiplayerAuthority(Name.ToString().ToInt());
        }
    }

    public override void _Process(double delta)
    {
        if (Multiplayer.MultiplayerPeer == null || Multiplayer.GetUniqueId().ToString() == Name.ToString())
        {
            // The client which this player represent will update the controls state, and notify it to everyone.
            GetNode<PlayerControls>("Inputs").Update();
        }

        if (Multiplayer.MultiplayerPeer == null || IsMultiplayerAuthority())
        {
            // The server updates the position that will be notified to the clients.
            SyncedPosition = Position;

            // And increase the bomb cooldown spawning one if the client wants to
            _lastBombTime += delta;

            if (!Stunned && IsMultiplayerAuthority() && GetNode<PlayerControls>("Inputs").Bombing &&
                _lastBombTime >= _bombRate)
            {
                _lastBombTime = 0;
                GetNode<MultiplayerSpawner>("../../BombSpawner").Spawn(new Array([Position, Name.ToString().ToInt()]));
            }
        }
        else
        {
            // The client simply updates the position to the last known one.
            Position = SyncedPosition;
        }

        if (!Stunned)
        {
            // Everybody runs physics. i.e. clients try to predict where they will be during the next frame.
            Velocity = GetNode<PlayerControls>("Inputs").Motion * _motionSpeed;
            MoveAndSlide();
        }

        // Also update the animation based on the last known player input state.
        var newAnimation = "standing";
        var motion = GetNode("Inputs").Get("motion");
        if (motion.AsVector2().Y < 0)
        {
            newAnimation = "walk_up";
        }
        else if (motion.AsVector2().Y > 0)
        {
            newAnimation = "walk_down";
        }
        else if (motion.AsVector2().X < 0)
        {
            newAnimation = "walk_left";
        }
        else if (motion.AsVector2().X > 0)
        {
            newAnimation = "walk_right";
        }

        if (Stunned)
        {
            newAnimation = "stunned";
        }

        if (newAnimation != _currentAnim)
        {
            _currentAnim = newAnimation;
            GetNode<AnimationPlayer>("anim").Play(newAnimation);
        }
    }

    public void SetPlayerName(string value)
    {
        var label = GetNode<Label>("label");
        label.Text = value;
        // Assign a random color to the player based on its name.
        var color = GameState.GetPlayerColor(value);

        label.Modulate = color;
        GetNode<Sprite2D>("sprite").Modulate = color;
    }

    [Rpc(CallLocal = true)]
    public void Exploded(int byWho)
    {
        if (Stunned)
        {
            return;
        }

        Stunned = true;
        GetNode<AnimationPlayer>("anim").Play("stunned");
    }
}
