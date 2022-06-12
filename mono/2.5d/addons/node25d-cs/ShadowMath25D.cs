using Godot;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// Adds a simple shadow below an object.
/// Place this ShadowMath25D node as a child of a Shadow25D, which
/// is below the target object in the scene tree (not as a child).
/// </summary>
[Tool]
public class ShadowMath25D : KinematicBody
{
    /// <summary>
    /// The maximum distance below objects that shadows will appear.
    /// </summary>
    public real_t shadowLength = 1000;
    private Node25D shadowRoot;
    private Spatial targetMath;

    public override void _Ready()
    {
        shadowRoot = GetParent<Node25D>();
        int index = shadowRoot.GetPositionInParent();
        targetMath = shadowRoot.GetParent().GetChild<Node25D>(index - 1).GetChild<Spatial>(0);
    }

    public override void _Process(real_t delta)
    {
        if (targetMath == null)
        {
            if (shadowRoot != null)
            {
                shadowRoot.Visible = false;
            }
            return; // Shadow is not in a valid place.
        }

        Translation = targetMath.Translation;
        var k = MoveAndCollide(Vector3.Down * shadowLength);
        if (k == null)
        {
            shadowRoot.Visible = false;
        }
        else
        {
            shadowRoot.Visible = true;
            GlobalTransform = Transform;
        }
    }
}
