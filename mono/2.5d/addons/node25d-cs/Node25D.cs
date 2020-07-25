using Godot;
using System;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// This node converts a 3D position to 2D using a 2.5D transformation matrix.
/// The transformation of its 2D form is controlled by its 3D child.
/// </summary>
[Tool]
public class Node25D : Node2D, IComparable<Node25D>
{
    /// <summary>
    /// The number of 2D units in one 3D unit. Ideally, but not necessarily, an integer.
    /// </summary>
    public const int SCALE = 32;

    [Export] public Vector3 spatialPosition
    {
        get
        {
            if (spatialNode == null)
            {
                spatialNode = GetChild<Spatial>(0);
            }
            return spatialNode.Translation;
        }
        set
        {
            transform25D.spatialPosition = value;
            if (spatialNode != null)
            {
                spatialNode.Translation = value;
            }
            else if (GetChildCount() > 0)
            {
                spatialNode = GetChild<Spatial>(0);
            }
        }
    }

    private Spatial spatialNode;
    private Transform25D transform25D;

    public Basis25D Basis25D
    {
        get { return transform25D.basis; }
    }

    public Transform25D Transform25D
    {
        get { return transform25D; }
    }

    public override void _Ready()
    {
        Node25DReady();
    }

    public override void _Process(real_t delta)
    {
        Node25DProcess();
    }

    /// <summary>
    /// Call this method in _Ready, or before Node25DProcess is run.
    /// </summary>
    protected void Node25DReady()
    {
        if (GetChildCount() > 0)
        {
            spatialNode = GetChild<Spatial>(0);
        }
        // Changing the basis here will change the default for all Node25D instances.
        transform25D = new Transform25D(Basis25D.FortyFive * SCALE);
    }

    /// <summary>
    /// Call this method in _Process, or whenever the position of this object changes.
    /// </summary>
    protected void Node25DProcess()
    {
        if (transform25D.basis == new Basis25D())
        {
            SetViewMode(0);
        }
        CheckViewMode();
        if (spatialNode != null)
        {
            transform25D.spatialPosition = spatialNode.Translation;
        }
        else if (GetChildCount() > 0)
        {
            spatialNode = GetChild<Spatial>(0);
        }

        GlobalPosition = transform25D.FlatPosition;
    }

    public void SetViewMode(int viewModeIndex)
    {
        switch (viewModeIndex)
        {
            case 0:
                transform25D.basis = Basis25D.FortyFive * SCALE;
                break;
            case 1:
                transform25D.basis = Basis25D.Isometric * SCALE;
                break;
            case 2:
                transform25D.basis = Basis25D.TopDown * SCALE;
                break;
            case 3:
                transform25D.basis = Basis25D.FrontSide * SCALE;
                break;
            case 4:
                transform25D.basis = Basis25D.ObliqueY * SCALE;
                break;
            case 5:
                transform25D.basis = Basis25D.ObliqueZ * SCALE;
                break;
        }
    }

    private void CheckViewMode()
    {
        if (Input.IsActionJustPressed("forty_five_mode"))
        {
            SetViewMode(0);
        }
        else if (Input.IsActionJustPressed("isometric_mode"))
        {
            SetViewMode(1);
        }
        else if (Input.IsActionJustPressed("top_down_mode"))
        {
            SetViewMode(2);
        }
        else if (Input.IsActionJustPressed("front_side_mode"))
        {
            SetViewMode(3);
        }
        else if (Input.IsActionJustPressed("oblique_y_mode"))
        {
            SetViewMode(4);
        }
        else if (Input.IsActionJustPressed("oblique_z_mode"))
        {
            SetViewMode(5);
        }
    }

    public int CompareTo(object obj)
    {
        if (obj is Node25D)
        {
            return CompareTo((Node25D)obj);
        }
        return 1;
    }

    public int CompareTo(Node25D other)
    {
        real_t thisIndex = transform25D.spatialPosition.y + 0.001f * (transform25D.spatialPosition.x + transform25D.spatialPosition.z);
        real_t otherIndex = other.transform25D.spatialPosition.y + 0.001f * (other.transform25D.spatialPosition.x + other.transform25D.spatialPosition.z);
        real_t diff = thisIndex - otherIndex;
        if (diff > 0)
        {
            return 1;
        }
        if (diff < 0)
        {
            return -1;
        }
        return 0;
    }
}
