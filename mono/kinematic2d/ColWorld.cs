using Godot;

public class ColWorld : Node2D
{
    public void _OnPrincessBodyEnter(KinematicBody2D body)
    {
        if (body.GetName() == "player")
        {
            (FindNode("youwin") as Label)?.Show();
        }
    }
}