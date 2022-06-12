using Godot;
using System;

public class Ball : Area2D
{
    private const int DefaultSpeed = 100;

    private Vector2 _direction = Vector2.Left;
    private bool _stopped = false;
    private float _speed = DefaultSpeed;
    private Vector2 _screenSize;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        _screenSize = GetViewportRect().Size;
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        _speed += delta;
        // Ball will move normally for both players,
        // even if it's slightly out of sync between them,
        // so each player sees the motion as smooth and not jerky.
        if (!_stopped)
        {
            Translate(_speed * delta * _direction);
        }

        // Check screen bounds to make ball bounce.
        var ballPosition = Position;
        if ((ballPosition.y < 0 && _direction.y < 0) || (ballPosition.y > _screenSize.y && _direction.y > 0))
        {
            _direction.y = -_direction.y;
        }

        if (IsNetworkMaster())
        {
            // Only the master will decide when the ball is out in
            // the left side (it's own side). This makes the game
            // playable even if latency is high and ball is going
            // fast. Otherwise ball might be out in the other
            // player's screen but not this one.
            if (ballPosition.x < 0)
            {
                GetParent().Rpc("UpdateScore", false);
                Rpc("ResetBall", false);
            }
            else
            {
                // Only the puppet will decide when the ball is out in
                // the right side, which is it's own side. This makes
                // the game playable even if latency is high and ball
                // is going fast. Otherwise ball might be out in the
                // other player's screen but not this one.
                if (ballPosition.x > _screenSize.x)
                {
                    GetParent().Rpc("UpdateScore", true);
                    Rpc("ResetBall", true);
                }
            }
        }
    }

    [Sync]
    private void Bounce(bool left, float random)
    {
        // Using sync because both players can make it bounce.
        if (left)
        {
            _direction.x = Mathf.Abs(_direction.x);
        }
        else
        {
            _direction.x = -Mathf.Abs(_direction.x);
        }

        _speed *= 1.1f;
        _direction.y = random * 2.0f - 1;
        _direction = _direction.Normalized();
    }

    [Sync]
    private void Stop()
    {
        _stopped = true;
    }

    [Sync]
    private void ResetBall(bool forLeft)
    {
        Position = _screenSize / 2;
        _direction = forLeft ? Vector2.Left : Vector2.Right;
        _speed = DefaultSpeed;
    }
}
