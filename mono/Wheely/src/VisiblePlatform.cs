using Godot;
using System;

public class VisiblePlatform : CollisionPolygon2D{
    /// Using this class makes the Polygon2D child visible in the game
    
    public override void _Ready(){
        for(int i=0; i<this.GetChildCount(); i++){
            var child = this.GetChild(i);
            if(child is Polygon2D){
                Polygon2D visiblePolygon = (Polygon2D)GetChild(0);
                visiblePolygon.Polygon = this.Polygon;
                return;
            }
        }
        throw new Exception("VisiblePlatform must have visible Polygon2D Child");
    }
}
