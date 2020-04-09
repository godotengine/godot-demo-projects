using Godot;
using StateMachine;
using Godot.Collections;
using System;

public class CharacterController : KinematicBody
{

	String[] states;
	FSM machine;
	Vector3 velocity;

	float speed;
	[Export]
	public float gravity = 20f;
	[Export]
	public float max_speed = 10f;

	private sbyte side = 1;
	[Export]
	public NodePath path_animation;
	private AnimationPlayer animationPlayer;


	public sbyte Side { get => side; set {
		side = value;
	} 
	}

	public override void _Ready()
	{
		animationPlayer = GetNode<AnimationPlayer>(path_animation);
		states = new String[]{"Idle","Walk"};
		machine = new FSM(states,this);

	}

	public void OnEnterIdle() {
		animationPlayer.CurrentAnimation = "Idle";
	}

	public void OnUpdateIdle() {

		if (GetSpeed() > .5) {
			machine.ChangeState("Walk");
		}
	}

	public void OnExitIdle() {

	}

	public void OnEnterWalk() {
		animationPlayer.PlaybackSpeed = 1.5f;
		animationPlayer.CurrentAnimation = "RunTest";
	}
	public void OnUpdateWalk() {
		if (GetSpeed() < .5) {
			machine.ChangeState("Idle");
		}

	}
	public void OnExitWalk() {
		animationPlayer.PlaybackSpeed = 1f;

	}

	Vector3 new_dir = Vector3.Zero;
	float new_angle = 0f;
	private void LookDirection() {

		if (!dir.IsEqualApprox(Vector3.Zero)) new_dir = dir;
		float angle = Mathf.Atan2(new_dir.x,new_dir.z);
		new_angle = Mathf.LerpAngle(new_angle,angle,0.25f);
		float deg = Mathf.Rad2Deg(new_angle);
		RotationDegrees = new Vector3(RotationDegrees.x,deg,RotationDegrees.z);
	}

	private float GetSpeed() {
		return (Mathf.Abs( velocity.x ) + Mathf.Abs( velocity.z) )/2;
	}
	Vector3 dir = Vector3.Zero;
	public override void _Process(float delta)
	{
		Transform cam_form = GetViewport().GetCamera().GlobalTransform;
		Godot.Collections.Array<bool> inputs =  new Godot.Collections.Array<bool> {
			Input.IsActionPressed("ui_up") ,
			Input.IsActionPressed("ui_down") ,
			Input.IsActionPressed("ui_left") ,
			Input.IsActionPressed("ui_right")
		};
		dir = Vector3.Zero;
		if (inputs[0]) dir += -cam_form.basis[2];
		if (inputs[1]) dir += cam_form.basis[2];
		if (inputs[2]) dir += -cam_form.basis[0];
		if (inputs[3]) dir += cam_form.basis[0];

		

		if (!IsOnFloor()) velocity.y += gravity;
		else velocity.y = 0;

		if (Input.IsActionJustPressed("cmd_jump") && IsOnFloor()) {
			velocity.y = 5;
		}

		velocity = new Vector3(dir.x * max_speed , velocity.y, dir.z * max_speed);
		MoveAndSlide(velocity,Vector3.Up);
		LookDirection();
		machine.Update();	
	}



  
}
