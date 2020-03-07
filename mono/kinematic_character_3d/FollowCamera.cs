using Godot;
using System.Collections.Generic;

public class FollowCamera : Camera
{

    private const float MAX_HEIGHT = 2.0f;
    private const float MIN_HEIGHT = 0.0f;

    [Export]
    private float minDistance = 0.5f;
    [Export]
    private float maxDistance = 5.5f;
    [Export]
    private float angleVadjust = 0.0f;

    private List<RID> collisionExceptions;
    private Node targetNode;

    public override void _Ready()
    {
        this.collisionExceptions = new List<RID>();
        this.targetNode = GetParent() as Spatial;

        CollisionObject targetParentNode = this.targetNode.GetParent() as CollisionObject;
        this.collisionExceptions.Add(targetParentNode.GetRid());

        SetAsToplevel(true);
    }

    public override void _PhysicsProcess(float delta)
    {
        Vector3 targetPosition = (this.targetNode as Spatial).GlobalTransform.origin;
        Vector3 cameraPosition = this.GlobalTransform.origin;

        Vector3 deltaPosition = cameraPosition - targetPosition;

        if (deltaPosition.Length() < minDistance)
        {
            deltaPosition = deltaPosition.Normalized() * this.minDistance;
        }
        else if (deltaPosition.Length() > maxDistance)
        {
            deltaPosition = deltaPosition.Normalized() * this.maxDistance;
        }

        if (deltaPosition.y > MAX_HEIGHT)
        {
            deltaPosition.y = MAX_HEIGHT;
        }
        if (deltaPosition.y < MIN_HEIGHT)
        {
            deltaPosition.y = MIN_HEIGHT;
        }

        cameraPosition = targetPosition + deltaPosition;

        LookAtFromPosition(cameraPosition, targetPosition, Vector3.Up);

        Transform newTransform = this.Transform;
        newTransform.basis = new Basis(newTransform.basis[0], Mathf.Deg2Rad(this.angleVadjust)) * newTransform.basis;
        this.Transform = newTransform;
    }

}
