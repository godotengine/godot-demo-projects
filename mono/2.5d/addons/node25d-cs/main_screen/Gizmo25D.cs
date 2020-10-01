using Godot;

// This is identical to the GDScript version, yet it doesn't work.
[Tool]
public class Gizmo25D : Node2D
{
    // Not pixel perfect for all axes in all modes, but works well enough.
    // Rounding is not done until after the movement is finished.
    private const bool RoughlyRoundToPixels = true;

    // Set when the node is created.
    public Node25D node25d;
    public Spatial spatialNode;

    // Input from Viewport25D, represents if the mouse is clicked.
    public bool wantsToMove = false;

    // Used to control the state of movement.
    private bool _moving = false;
    private Vector2 _startPosition = Vector2.Zero;

    // Stores state of closest or currently used axis.
    private int dominantAxis;

    private Node2D linesRoot;
    private Line2D[] lines = new Line2D[3];

    public override void _Ready()
    {
        linesRoot = GetChild<Node2D>(0);
        lines[0] = linesRoot.GetChild<Line2D>(0);
        lines[1] = linesRoot.GetChild<Line2D>(1);
        lines[2] = linesRoot.GetChild<Line2D>(2);
    }

    public override void _Process(float delta)
    {
        if (lines == null)
        {
            return; // Somehow this node hasn't been set up yet.
        }
        if (node25d == null)
        {
            return; // We're most likely viewing the Gizmo25D scene.
        }
        // While getting the mouse position works in any viewport, it doesn't do
	    // anything significant unless the mouse is in the 2.5D viewport.
	    Vector2 mousePosition = GetLocalMousePosition();
    	if (!_moving)
        {
    		// If the mouse is farther than this many pixels, it won't grab anything.
    		float closestDistance = 20.0f;
    		dominantAxis = -1;
    		for (int i = 0; i < 3; i++)
            {
                // Unrelated, but needs a loop too.
                Color modulateLine = lines[i].Modulate;
    			modulateLine.a = 0.8f;
                lines[i].Modulate = modulateLine;

    			var distance = DistanceToSegmentAtIndex(i, mousePosition);
    			if (distance < closestDistance)
                {
    				closestDistance = distance;
    				dominantAxis = i;
                }
            }
    		if (dominantAxis == -1)
            {
    			// If we're not hovering over a line, ensure they are placed correctly.
    			linesRoot.GlobalPosition = node25d.GlobalPosition;
    			return;
            }
        }

        Color modulate = lines[dominantAxis].Modulate;
    	modulate.a = 1;
        lines[dominantAxis].Modulate = modulate;

    	if (!wantsToMove)
        {
    		_moving = false;
        }
    	else if (wantsToMove && !_moving)
        {
    		_moving = true;
    		_startPosition = mousePosition;
        }

    	if (_moving)
        {
    		// Change modulate of unselected axes.
            modulate = lines[(dominantAxis + 1) % 3].Modulate;
    		modulate.a = 0.5f;
            lines[(dominantAxis + 1) % 3].Modulate = modulate;
            lines[(dominantAxis + 2) % 3].Modulate = modulate;

    		// Calculate mouse movement and reset for next frame.
    		var mouseDiff = mousePosition - _startPosition;
    		_startPosition = mousePosition;
    		// Calculate movement.
    		var projectedDiff = mouseDiff.Project(lines[dominantAxis].Points[1]);
    		var movement = projectedDiff.Length() / Node25D.SCALE;
    		if (Mathf.IsEqualApprox(Mathf.Pi, projectedDiff.AngleTo(lines[dominantAxis].Points[1])))
            {
    			movement *= -1;
            }
    		// Apply movement.
            Transform t = spatialNode.Transform;
    		t.origin += t.basis[dominantAxis] * movement;
            spatialNode.Transform = t;
        }
    	else
        {
    		// Make sure the gizmo is located at the object.
    		GlobalPosition = node25d.GlobalPosition;
    		if (RoughlyRoundToPixels)
            {
                Transform t = spatialNode.Transform;
    			t.origin = (t.origin * Node25D.SCALE).Round() / Node25D.SCALE;
                spatialNode.Transform = t;
            }
        }
    	// Move the gizmo lines appropriately.
    	linesRoot.GlobalPosition = node25d.GlobalPosition;
    	node25d.PropertyListChangedNotify();
    }

    // Initializes after _ready due to the onready vars, called manually in Viewport25D.gd.
    // Sets up the points based on the basis values of the Node25D.
    public void Initialize()
    {
	    var basis = node25d.Basis25D;
	    for (int i = 0; i < 3; i++)
        {
		    lines[i].Points[1] = basis[i] * 3;
        }
	    GlobalPosition = node25d.GlobalPosition;
	    spatialNode = node25d.GetChild<Spatial>(0);
    }


    // Figures out if the mouse is very close to a segment. This method is
    // specialized for this script, it assumes that each segment starts at
    // (0, 0) and it provides a deadzone around the origin.
    private float DistanceToSegmentAtIndex(int index, Vector2 point)
    {
	    if (lines == null)
        {
		    return Mathf.Inf;
        }
    	if (point.LengthSquared() < 400)
        {
		    return Mathf.Inf;
        }

	    Vector2 segmentEnd = lines[index].Points[1];
	    float lengthSquared = segmentEnd.LengthSquared();
	    if (lengthSquared < 400)
        {
    		return Mathf.Inf;
        }

	    var t = Mathf.Clamp(point.Dot(segmentEnd) / lengthSquared, 0, 1);
    	var projection = t * segmentEnd;
	    return point.DistanceTo(projection);
    }
}
