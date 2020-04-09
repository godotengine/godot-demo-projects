using Godot;
using System;

public class CameraLook : Camera
{
	[Export]
	public NodePath target_path = new NodePath();

	Spatial target;
	public override void _Ready()
	{
		target = GetNode<Spatial>(target_path);
	}
	
	public override void _Process(float delta) {
		LookAt(target.GlobalTransform.origin,Vector3.Up);
	}


}
