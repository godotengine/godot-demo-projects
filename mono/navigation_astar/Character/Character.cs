using Godot;
using System.Collections.Generic;

public class Character : Position2D
{
    private const float DefaultSpeed = 200.0f;
    private const float Mass = 10.0f;
    private const float ArriveDistance = 10.0f;
    private const int NextPositionIndex = 0;
    private const int NoMorePaths = 0;

    [Export]
    private float _speed = DefaultSpeed;

    private CharacterState _state;
    private List<Vector2> _path;
    private Vector2 _targetPointWorld;
    private Vector2 _targetPosition;
    private Vector2 _velocity;

    public override void _Ready()
    {
        _path = new List<Vector2>();
        _targetPointWorld = new Vector2();
        _targetPosition = new Vector2();
        _velocity = new Vector2();

        ChangeState(CharacterState.IDLE);
    }

    public override void _Process(float delta)
    {
        if (_state.Equals(CharacterState.FOLLOW))
        {
            MoveTo(_targetPointWorld);

            if (ArrivedTo(_targetPointWorld))
            {
                _path.RemoveAt(NextPositionIndex);

                if (_path.Count == NoMorePaths)
                {
                    ChangeState(CharacterState.IDLE);
                    return;
                }

                _targetPointWorld = _path[NextPositionIndex];
            }
        }
    }

    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionPressed("click"))
        {
            Vector2 globalMousePosition = GetGlobalMousePosition();
            if (Input.IsKeyPressed((int)KeyList.Shift))
            {
                GlobalPosition = globalMousePosition;
            }
            else
            {
                _targetPosition = globalMousePosition;
            }

            ChangeState(CharacterState.FOLLOW);
        }
    }

    private void ChangeState(CharacterState newState)
    {
        if (newState.Equals(CharacterState.FOLLOW))
        {
            PathFindingAStarTileSet tileMap = GetParent().GetNode("TileMap") as PathFindingAStarTileSet;
            _path = tileMap.GetPath(Position, _targetPosition);

            if (_path == null || _path.Count == 1)
            {
                ChangeState(CharacterState.IDLE);
                return;
            }

            _targetPointWorld = _path[1];
        }
        _state = newState;
    }

    private void MoveTo(Vector2 destination)
    {
        Vector2 desiredVelocity = (destination - Position).Normalized() * _speed;
        Vector2 steering = desiredVelocity - _velocity;
        _velocity += steering / Mass;
        Position += _velocity * GetProcessDeltaTime();
        Rotation = _velocity.Angle();
    }

    private bool ArrivedTo(Vector2 destination)
    {
        return Position.DistanceTo(destination) < ArriveDistance;
    }
}
