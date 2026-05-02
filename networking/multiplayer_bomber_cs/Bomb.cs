using Godot;
using System;
using System.Linq;
using Array = Godot.Collections.Array;

public partial class Bomb : Area2D
{
    private Array in_area = new();
    public int from_player;

    // Called from the animation.
    public void explode()
    {
        if (!IsMultiplayerAuthority())
        {
            // Explode only on authority.
            return;
        }

        for (int i = 0; i < in_area.Count; i++)
        {
            var item = in_area[i].AsGodotObject();
            if (item.HasMethod("exploded"))
            {
                // Checks if there is wall in between bomb and the object.
                var worldState = GetWorld2D().DirectSpaceState;
                var query = PhysicsRayQueryParameters2D.Create(Position, item.Get("position").AsVector2());
                query.HitFromInside = true;
                var result = worldState.IntersectRay(query);
                ;
                // TODO: double check. GDScript: `if result.collider is not TileMap:`
                if (result.TryGetValue("collider", out var collider) && collider.AsGodotObject() is not TileMapLayer)
                {
                    if (collider.Obj is Player pl)
                    {
                        pl.Rpc("exploded", from_player);
                    }

                    if (collider.Obj is Rock rock)
                    {
                        rock.Rpc("exploded", from_player);
                    }
                    
                }
            }
        }
    }

    void done()
    {
        if (IsMultiplayerAuthority())
        {
            QueueFree();
        }
    }

    void _on_bomb_body_enter(Node2D body)
    {
        if (!in_area.Contains(body))
        {
            in_area.Add(body);
        }
    }

    void _on_bomb_body_exit(Node2D body)
    {
        in_area.Remove(body);
    }
}
