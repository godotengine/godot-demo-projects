using Godot;
using System;

/// This code is only necessary to make the CollisionPolygon2D
/// drawn in the editor visible. (Note: you must have a 
/// have a visible "Polygon2D" child for this to work)
public class PlatformCollision : CollisionPolygon2D{
    public override void _Ready(){
        for(int i=0; i<this.GetChildCount(); i++){
            var child = this.GetChild(i);
            if(child is Polygon2D){
                Polygon2D visiblePolygon = (Polygon2D)GetChild(0);
                visiblePolygon.Polygon = this.Polygon;
                return;
            }
        }
        throw new Exception("PlatformCollison must have visible Polygon2D Child");
    }
}
