using Godot;

public partial class CubeMath : Node3D
{
    private static PackedScene cubePointScene = ResourceLoader.Load<PackedScene>("res://assets/cube/cube_point.tscn");

    private bool _isParentReady = false;
    private Node2D _parent;
    private Node3D[] _cubePointsMath = new Node3D[27]; // The math node of each 2.5D cube point
    private Node3D[] _cubeMathSpatials = new Node3D[27]; // The CubeMath children that find position.

    public override void _Ready()
    {
        _parent = GetParent<Node2D>();

        // Initialize the cube
        for (int i = 0; i < 27; i++)
        {
            int a = (i / 9) - 1;
            int b = (i / 3) % 3 - 1;
            int c = (i % 3) - 1;
            Vector3 spatialPosition = 5 * (a * Vector3.Right + b * Vector3.Up + c * Vector3.Back);

            _cubeMathSpatials[i] = new Node3D();
            _cubeMathSpatials[i].Position = spatialPosition;
            _cubeMathSpatials[i].Name = "CubeMath #" + i + ", " + a + " " + b + " " + c;
            AddChild(_cubeMathSpatials[i]);
        }
    }

    public override void _Process(float delta)
    {
        if (Input.IsActionPressed("exit"))
        {
            GetTree().Quit();
        }

        if (Input.IsActionJustPressed("view_cube_demo"))
        {
            GetTree().ChangeScene("res://assets/demo_scene.tscn");
            return;
        }

        if (_isParentReady)
        {
            RotateX(delta * (Input.GetActionStrength("move_back") - Input.GetActionStrength("move_forward")));
            RotateY(delta * (Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left")));
            RotateZ(delta * (Input.GetActionStrength("move_counterclockwise") - Input.GetActionStrength("move_clockwise")));
            if (Input.IsActionJustPressed("reset_position"))
            {
                Transform = Transform3D.Identity;
            }
            for (int i = 0; i < 27; i++)
            {
                _cubePointsMath[i].GlobalTransform = _cubeMathSpatials[i].GlobalTransform;
            }
        }
        else
        {
            // This code block will be run only once. It's not in _Ready() because the parent isn't set up there.
            for (int i = 0; i < 27; i++)
            {
                PackedScene myCubePointScene = cubePointScene.Duplicate(true) as PackedScene;
                Node25D cubePoint = myCubePointScene.Instantiate() as Node25D;
                cubePoint.Name = "CubePoint #" + i;
                _cubePointsMath[i] = cubePoint.GetChild<Node3D>(0);
                _parent.AddChild(cubePoint);
            }
            _isParentReady = true;
        }
    }
}
