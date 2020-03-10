using Godot;
using System.Collections.Generic;

public class Navigation : Navigation2D
{
    [Export]
    private float _characterSpeed = 350;
    private List<Vector2> _path;

    public override void _Ready()
    {
        _path = new List<Vector2>();
    }

    public override void _Input(InputEvent inputEvent)
    {
        if (!inputEvent.IsActionPressed("click"))
        {
            return;
        }
        Sprite character = GetNode("Character") as Sprite;
        UpdateNavigationPath(character.GetPosition(), GetLocalMousePosition());
    }

    public override void _Process(float delta)
    {
        float walkDistance = delta * _characterSpeed;
        MoveAlongPath(walkDistance);
    }

    private void UpdateNavigationPath(Vector2 startPosition, Vector2 endPosition)
    {
        _path.AddRange(GetSimplePath(startPosition, endPosition, true));
        SetProcess(true);
    }

    private void MoveAlongPath(float walkDistance)
    {
        Sprite character = GetNode("Character") as Sprite;
        Vector2 lastPosition = character.Position;

        while (_path.Count != 0)
        {
            float distanceBetweenPoints = lastPosition.DistanceTo(_path[0]);

            if (walkDistance < distanceBetweenPoints)
            {
                character.Position = lastPosition.LinearInterpolate(_path[0], walkDistance / distanceBetweenPoints);
                return;
            }

            walkDistance -= distanceBetweenPoints;
            lastPosition = _path[0];
            _path.Remove(lastPosition);
        }

        character.Position = lastPosition;
        SetProcess(false);
    }
}
