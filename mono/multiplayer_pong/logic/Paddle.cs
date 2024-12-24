using Godot;
using System;

public partial class Paddle : Area2D
{
    private const int MotionSpeed = 150;

    [Export] private bool _left = false;

    private float _motion = 0.0f;
    private bool _youHidden = false;
    private float _screenSizeY = 0.0f;

    public override void _Ready()
    {
        _screenSizeY = GetViewportRect().Size.Y;
    }

    public override void _Process(double delta)
    {
        // Is the master of the paddle.
        if (IsMultiplayerAuthority())
        {
            _motion = Input.GetActionStrength("move_down") - Input.GetActionStrength("move_up");
            if (!_youHidden && _motion != 0)
            {
                HideYouLabel();
            }

            _motion *= MotionSpeed;

            // Using unreliable to make sure position is updated as fast as possible,
            // even if one of the calls is dropped
            Rpc(nameof(SetPosAndMotion), Position, _motion);
        }
        else
        {
            if (!_youHidden)
            {
                HideYouLabel();
            }
        }
        Translate(new Vector2(0, _motion * (float)delta));

        // Set screen limits. Can't modify structs directly, so we create a new one.
        Position = new Vector2(Position.X, Mathf.Clamp(Position.Y, 16, _screenSizeY - 16));
    }

    [Rpc(TransferMode = MultiplayerPeer.TransferModeEnum.Unreliable)]
    private void SetPosAndMotion(Vector2 pos, float motion)
    {
        Position = pos;
        _motion = motion;
    }

    private void HideYouLabel()
    {
        _youHidden = true;
        GetNode<Label>("You").Hide();
    }

    private void OnPaddleAreaEnter(Area2D area)
    {
        if (IsMultiplayerAuthority())
        {
            area.Rpc("Bounce", _left, GD.Randf());
        }
    }
}
