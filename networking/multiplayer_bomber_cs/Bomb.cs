using Godot;
using System;
using System.Linq;
using Array = Godot.Collections.Array;

public partial class Bomb : Area2D
{
    private Array _inArea = new();
    public int FromPlayer;

    // Called from the animation.
    public void Explode()
    {
        if (!IsMultiplayerAuthority())
        {
            // Explode only on authority.
            return;
        }

        for (int i = 0; i < _inArea.Count; i++)
        {
            var item = _inArea[i].AsGodotObject();
            if (item.HasMethod("Exploded"))
            {
                // Checks if there is wall in between bomb and the object.
                var worldState = GetWorld2D().DirectSpaceState;
                var query = PhysicsRayQueryParameters2D.Create(Position, item.Get("position").AsVector2());
                query.HitFromInside = true;
                var result = worldState.IntersectRay(query);
                
                if (result.TryGetValue("collider", out var collider))
                {
                    if (collider.Obj is Player pl)
                    {
                        pl.Rpc("Exploded", FromPlayer);
                    }

                    if (collider.Obj is Rock rock)
                    {
                        rock.Rpc("Exploded", FromPlayer);
                    }
                }
            }
        }
    }

    void Done()
    {
        if (IsMultiplayerAuthority())
        {
            QueueFree();
        }
    }

    void _on_bomb_body_enter(Node2D body)
    {
        if (!_inArea.Contains(body))
        {
            _inArea.Add(body);
        }
    }

    void _on_bomb_body_exit(Node2D body)
    {
        _inArea.Remove(body);
    }
}
