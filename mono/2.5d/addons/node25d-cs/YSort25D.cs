using Godot;
using System.Collections.Generic;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// Assigns Z-index values to Node25D children.
/// </summary>
[Tool] // Commented out because it sometimes crashes the editor when running the game...
public partial class YSort25D : Node // Note: NOT Node2D, Node25D, or Node2D
{
    /// <summary>
    /// Whether or not to automatically call Sort() in _Process().
    /// </summary>
    [Export]
    public bool sortEnabled = true;

    public override void _Process(real_t delta)
    {
        if (sortEnabled)
        {
            Sort();
        }
    }

    /// <summary>
    /// Call this method in _Process, or whenever you want to sort children.
    /// </summary>
    public void Sort()
    {
        var children = GetParent().GetChildren();
        if (children.Count > 4000)
        {
            GD.PrintErr("Sorting failed: Max number of YSort25D nodes is 4000.");
        }
        List<Node25D> node25dChildren = new List<Node25D>();

        foreach (Node n in children)
        {
            if (n is Node25D node25d)
            {
                node25dChildren.Add(node25d);
            }
        }

        node25dChildren.Sort();

        int zIndex = -4000;
        for (int i = 0; i < node25dChildren.Count; i++)
        {
            node25dChildren[i].ZIndex = zIndex;
            // Increment by 2 each time, to allow for shadows in-between.
            // This does mean that we have a limit of 4000 total sorted Node25Ds.
            zIndex += 2;
        }
    }
}
