using Godot;
using System;
using Godot.NativeInterop;
using Array = Godot.Collections.Array;

public partial class Player : CharacterBody2D
{
    // The player's movement speed (in pixels per second).
    private static float MOTION_SPEED = 90.0f;

    // The delay before which you can place a new bomb (in seconds).
    private static float BOMB_RATE = 0.5f;

    [Export] public Vector2 synced_position = new Vector2();

    [Export] private bool stunned = false;

    private double last_bomb_time = BOMB_RATE;
    private string current_anim = "";


    public override void _Ready()
    {
        this.stunned = false;
        Console.WriteLine("Pos:" + synced_position);
        Position = synced_position;
        if (Name.ToString().IsValidInt())
        {
            GetNode("Inputs/InputsSync").Call("set_multiplayer_authority", Name.ToString().ToInt());
        }
    }

    public override void _Process(double delta)
    {
        if (Multiplayer.MultiplayerPeer == null || Multiplayer.GetUniqueId().ToString() == Name.ToString())
        {
            // The client which this player represent will update the controls state, and notify it to everyone.
            GetNode("Inputs").Call("update");
        }

        if (Multiplayer.MultiplayerPeer == null || IsMultiplayerAuthority())
        {
            // The server updates the position that will be notified to the clients.
            synced_position = Position;

            // And increase the bomb cooldown spawning one if the client wants to
            last_bomb_time += delta;

            if (!stunned && IsMultiplayerAuthority() && GetNode("Inputs").Get("bombing").AsBool() &&
                last_bomb_time >= BOMB_RATE)
            {
                last_bomb_time = 0;
                GetNode<MultiplayerSpawner>("../../BombSpawner").Spawn(new Array([Position, Name.ToString().ToInt()]));
            }
        }
        else
        {
            // The client simply updates the position to the last known one.
            Position = synced_position;
        }

        if (!stunned)
        {
            // Everybody runs physics. i.e. clients try to predict where they will be during the next frame.
            Velocity = GetNode("Inputs").Get("motion").AsVector2() * MOTION_SPEED;
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

        if (stunned)
        {
            newAnimation = "stunned";
        }

        if (newAnimation != current_anim)
        {
            current_anim = newAnimation;
            GetNode<AnimationPlayer>("anim").Play(newAnimation);
        }
    }

    public void set_player_name(string value)
    {
        var label = GetNode<Label>("label");
        label.Text = value;
        // Assign a random color to the player based on its name.
        var color = GameState.get_player_color(value);

        label.Modulate = color;
        GetNode<Sprite2D>("sprite").Modulate = color;
    }

    [Rpc(CallLocal = true)]
    public void exploded(int _by_who)
    {
        if (stunned)
        {
            return;
        }

        stunned = true;
        GetNode<AnimationPlayer>("anim").Play("stunned");
    }
}
