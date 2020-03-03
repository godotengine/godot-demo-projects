using Godot;
using System;
using System.Runtime.InteropServices;

#if GODOT_REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

/// <summary>
/// Basis25D structure for performing 2.5D transform math.
/// Note: All code assumes that Y is UP in 3D, and DOWN in 2D.
/// A top-down view has a Y axis component of (0, 0), with a Z axis component of (0, 1).
/// For a front side view, Y is (0, -1) and Z is (0, 0).
/// Remember that Godot's 2D mode has the Y axis pointing DOWN on the screen.
/// </summary>
[Serializable]
[StructLayout(LayoutKind.Sequential)]
public struct Basis25D : IEquatable<Basis25D>
{
    // Also matrix columns, the directions to move on screen for each unit change in 3D.
    public Vector2 x;
    public Vector2 y;
    public Vector2 z;

    // Also matrix rows, the parts of each vector that contribute to moving in a screen direction.
    // Setting a row to zero means no movement in that direction.
    public Vector3 Row0
    {
        get { return new Vector3(x.x, y.x, z.x); }
        set
        {
            x.x = value.x;
            y.x = value.y;
            z.x = value.z;
        }
    }

    public Vector3 Row1
    {
        get { return new Vector3(x.y, y.y, z.y); }
        set
        {
            x.y = value.x;
            y.y = value.y;
            z.y = value.z;
        }
    }

    public Vector2 this[int columnIndex]
    {
        get
        {
            switch (columnIndex)
            {
                case 0: return x;
                case 1: return y;
                case 2: return z;
                default: throw new IndexOutOfRangeException();
            }
        }
        set
        {
            switch (columnIndex)
            {
                case 0: x = value; return;
                case 1: y = value; return;
                case 2: z = value; return;
                default: throw new IndexOutOfRangeException();
            }
        }
    }

    public real_t this[int columnIndex, int rowIndex]
    {
        get
        {
            return this[columnIndex][rowIndex];
        }
        set
        {
            Vector2 v = this[columnIndex];
            v[rowIndex] = value;
            this[columnIndex] = v;
        }
    }

    private static readonly Basis25D _topDown = new Basis25D(1, 0, 0, 0, 0, 1);
    private static readonly Basis25D _frontSide = new Basis25D(1, 0, 0, -1, 0, 0);
    private static readonly Basis25D _fortyFive = new Basis25D(1, 0, 0, -0.70710678118f, 0, 0.70710678118f);
    private static readonly Basis25D _isometric = new Basis25D(0.86602540378f, 0.5f, 0, -1, -0.86602540378f, 0.5f);
    private static readonly Basis25D _obliqueY = new Basis25D(1, 0, -0.70710678118f, -0.70710678118f, 0, 1);
    private static readonly Basis25D _obliqueZ = new Basis25D(1, 0, 0, -1, -0.70710678118f, 0.70710678118f);

    public static Basis25D TopDown { get { return _topDown; } }
    public static Basis25D FrontSide { get { return _frontSide; } }
    public static Basis25D FortyFive { get { return _fortyFive; } }
    public static Basis25D Isometric { get { return _isometric; } }
    public static Basis25D ObliqueY { get { return _obliqueY; } }
    public static Basis25D ObliqueZ { get { return _obliqueZ; } }

    /// <summary>
    /// Creates a Dimetric Basis25D from the angle between the Y axis and the others.
    /// Dimetric(Tau/3) or Dimetric(2.09439510239) is the same as Isometric.
    /// Try to keep this number away from a multiple of Tau/4 (or Pi/2) radians.
    /// </summary>
    /// <param name="angle">The angle, in radians, between the Y axis and the X/Z axes.</param>
    public static Basis25D Dimetric(real_t angle)
    {
        real_t sin = Mathf.Sin(angle);
        real_t cos = Mathf.Cos(angle);
        return new Basis25D(sin, -cos, 0, -1, -sin, -cos);
    }

    // Constructors
    public Basis25D(Basis25D b)
    {
        x = b.x;
        y = b.y;
        z = b.z;
    }
    public Basis25D(Vector2 xAxis, Vector2 yAxis, Vector2 zAxis)
    {
        x = xAxis;
        y = yAxis;
        z = zAxis;
    }
    public Basis25D(real_t xx, real_t xy, real_t yx, real_t yy, real_t zx, real_t zy)
    {
        x = new Vector2(xx, xy);
        y = new Vector2(yx, yy);
        z = new Vector2(zx, zy);
    }

    public static Basis25D operator *(Basis25D b, real_t s)
    {
        b.x *= s;
        b.y *= s;
        b.z *= s;
        return b;
    }

    public static Basis25D operator /(Basis25D b, real_t s)
    {
        b.x /= s;
        b.y /= s;
        b.z /= s;
        return b;
    }

    public static bool operator ==(Basis25D left, Basis25D right)
    {
        return left.Equals(right);
    }

    public static bool operator !=(Basis25D left, Basis25D right)
    {
        return !left.Equals(right);
    }

    public override bool Equals(object obj)
    {
        if (obj is Basis25D)
        {
            return Equals((Basis25D)obj);
        }
        return false;
    }

    public bool Equals(Basis25D other)
    {
        return x.Equals(other.x) && y.Equals(other.y) && z.Equals(other.z);
    }

    public bool IsEqualApprox(Basis25D other)
    {
        return x.IsEqualApprox(other.x) && y.IsEqualApprox(other.y) && z.IsEqualApprox(other.z);
    }

    public override int GetHashCode()
    {
        return y.GetHashCode() ^ x.GetHashCode() ^ z.GetHashCode();
    }

    public override string ToString()
    {
        string s = String.Format("({0}, {1}, {2})", new object[]
        {
            x.ToString(),
            y.ToString(),
            z.ToString()
        });
        return s;
    }

    public string ToString(string format)
    {
        string s = String.Format("({0}, {1}, {2})", new object[]
        {
            x.ToString(format),
            y.ToString(format),
            z.ToString(format)
        });
        return s;
    }
}
