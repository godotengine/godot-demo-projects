using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Navigation : Navigation2D
{
	// member variables
    private const int SPEED = 200;

    private Vector2 begin;
    private Vector2 end;
    private List<Vector2> path = new List<Vector2>();

    private Sprite agent;

    public override void _Ready()
    {		
        agent = GetNode("Agent") as Sprite;
    }

    public override void _Process(float delta)
    {
        if (path.Count > 1)
        {
            float toWalk = delta * SPEED;
            while (toWalk > 0 && path.Count >= 2)
            {
                Vector2 pFrom = path.Last();
                Vector2 pTo = path[path.Count - 2];
                float d = pFrom.DistanceTo(pTo);

                if (d <= toWalk)
                {
                    path.RemoveAt(path.Count - 1);
                    toWalk -= d;
                }
                else
                {
                    path[path.Count - 1] = pFrom.LinearInterpolate(pTo, toWalk / d);
                    toWalk = 0;
                }
            }

            agent.Position = path.Last();

            if (path.Count < 2)
            {
                path.Clear();
                SetProcess(false);
                GD.Print("Destination Reached");
            }
        }
        else
            SetProcess(false);
    }

    private void UpdatePath()
    {
        path = GetSimplePath(begin, end, true).ToList();
        path.Reverse();

        SetProcess(true);
    }

    public override void _Input(InputEvent _event)
    {
        if (_event is InputEventMouseButton mouse)
        {
            if (mouse.Pressed && mouse.ButtonIndex == 1)
            {
                GD.Print($"Click Pos: {mouse.Position}");
                begin = agent.Position;

				// Mouse to local navigation coordinates
                end = mouse.Position - this.Position;
                UpdatePath();
            }
        }
	}
}