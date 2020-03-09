using Godot;
using System.Collections.Generic;

public class FollowCamera : Camera
{
    private const float MaxHeight = 2.0f;
    private const float MinHeight = 0.0f;

    [Export]
    private float _minDistance = 0.5f;
    [Export]
    private float _maxDistance = 5.5f;
    [Export]
    private float _angleVadjust = 0.0f;

    private List<RID> _collisionExceptions;
    private Node _targetNode;

    public override void _Ready()
    {
        _collisionExceptions = new List<RID>();
        _targetNode = GetParent() as Spatial;

        CollisionObject targetParentNode = _targetNode.GetParent() as CollisionObject;
        _collisionExceptions.Add(targetParentNode.GetRid());

        SetAsToplevel(true);
    }

    public override void _PhysicsProcess(float delta)
    {
        Vector3 targetPosition = (_targetNode as Spatial).GlobalTransform.origin;
        Vector3 cameraPosition = GlobalTransform.origin;

        Vector3 deltaPosition = cameraPosition - targetPosition;

        if (deltaPosition.Length() < _minDistance)
        {
            deltaPosition = deltaPosition.Normalized() * _minDistance;
        }
        else if (deltaPosition.Length() > _maxDistance)
        {
            deltaPosition = deltaPosition.Normalized() * _maxDistance;
        }

        if (deltaPosition.y > MaxHeight)
        {
            deltaPosition.y = MaxHeight;
        }
        if (deltaPosition.y < MinHeight)
        {
            deltaPosition.y = MinHeight;
        }

        cameraPosition = targetPosition + deltaPosition;

        LookAtFromPosition(cameraPosition, targetPosition, Vector3.Up);

        Transform newTransform = Transform;
        newTransform.basis = new Basis(newTransform.basis[0], Mathf.Deg2Rad(_angleVadjust)) * newTransform.basis;
        Transform = newTransform;
    }
}
