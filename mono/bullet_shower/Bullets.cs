using System.Collections.Generic;
using Godot;

/// <summary>
/// This demo is an example of controlling a high number of 2D objects with logic
/// and collision without using nodes in the scene. This technique is a lot more
/// efficient than using instancing and nodes, but requires more programming and
/// is less visual. Bullets are managed together in the `bullets.cs` script.
/// </summary>
public partial class Bullets : Node2D
{
    private const int BulletCount = 500;
    private const int SpeedMin = 20;
    private const int SpeedMax = 80;

    private Texture2D _bulletImage;
    private List<Bullet> _bullets = new List<Bullet>();
    private Rid _shape;

    class Bullet
    {
        public Vector2 Position;
        public double Speed;
        public Rid Body;
    }

    public override void _Ready()
    {
        _bulletImage = GD.Load<Texture2D>("res://bullet.png");
        _shape = PhysicsServer2D.CircleShapeCreate();
        // Set the collision shape's radius for each bullet in pixels.
        PhysicsServer2D.ShapeSetData(_shape, 8);

        for (int i = 0; i < BulletCount; i++)
        {
            Bullet bullet = new Bullet
            {
                Position = Vector2.Zero,
                Speed = GD.RandRange(SpeedMin, SpeedMax),
                Body = PhysicsServer2D.BodyCreate()
            };

            PhysicsServer2D.BodySetSpace(bullet.Body, GetWorld2D().Space);
            PhysicsServer2D.BodyAddShape(bullet.Body, _shape);
            // Don't make bullets check collision with other bullets to improve performance.
            PhysicsServer2D.BodySetCollisionMask(bullet.Body, 0);

            // Place bullets randomly on the viewport and move bullets outside the
            // play area so that they fade in nicely.
            bullet.Position = new Vector2(
                (float)(GD.RandRange(0, GetViewportRect().Size.X) + GetViewportRect().Size.X),
                (float)GD.RandRange(0, GetViewportRect().Size.Y)
            );
            Transform2D transform2d = new Transform2D
            {
                Origin = bullet.Position
            };
            PhysicsServer2D.BodySetState(bullet.Body, PhysicsServer2D.BodyState.Transform, transform2d);

            _bullets.Add(bullet);
        }
    }

    public override void _Process(double delta)
    {
        // Order the CanvasItem to update every frame.
        QueueRedraw();
    }

    public override void _PhysicsProcess(double delta)
    {
        var transform2d = new Transform2D();
        var offset = GetViewportRect().Size.X + 16;
        foreach (Bullet bullet in _bullets)
        {
            bullet.Position.X -= (float)(bullet.Speed * delta);

            if (bullet.Position.X < -16)
            {
                // Move the bullet back to the right when it left the screen.
                bullet.Position.X = offset;
            }

            transform2d.Origin = bullet.Position;
            PhysicsServer2D.BodySetState(bullet.Body, PhysicsServer2D.BodyState.Transform, transform2d);
        }
    }

    /// <summary>
    /// Instead of drawing each bullet individually in a script attached to each bullet,
    /// we are drawing *all* the bullets at once here.
    /// </summary>
    public override void _Draw()
    {
        var offset = -_bulletImage.GetSize() * 0.5f;
        foreach (Bullet bullet in _bullets)
        {
            DrawTexture(_bulletImage, bullet.Position + offset);
        }
    }

    /// <summary>
    /// Perform cleanup operations (required to exit without error messages in the console).
    /// </summary>
    public override void _ExitTree()
    {
        foreach (Bullet bullet in _bullets)
        {
            PhysicsServer2D.FreeRid(bullet.Body);
        }

        PhysicsServer2D.FreeRid(_shape);
        _bullets.Clear();
    }
}
