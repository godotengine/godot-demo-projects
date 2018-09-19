using Godot;

public class Enemy : KinematicBody2D, IShootable
{
    readonly Vector2 GRAVITY_VEC = new Vector2(0, 900);
    readonly Vector2 FLOOR_NORMAL = new Vector2(0, -1);

    const float WALK_SPEED = 70;

    enum State
    {
        Walking,
        Killed,
    }

    Vector2 linear_velocity = Vector2.Zero;
    int direction = -1;
    string anim = "";

    State state = State.Walking;

    RayCast2D detect_floor_left;
    RayCast2D detect_wall_left;
    RayCast2D detect_floor_right;
    RayCast2D detect_wall_right;
    Sprite sprite;

    public override void _Ready()
    {
        base._Ready();

        detect_floor_left = GetNode<RayCast2D>("detect_floor_left");
        detect_wall_left = GetNode<RayCast2D>("detect_wall_left");
        detect_floor_right = GetNode<RayCast2D>("detect_floor_right");
        detect_wall_right = GetNode<RayCast2D>("detect_wall_right");
        sprite = GetNode<Sprite>("sprite");
    }

    public override void _PhysicsProcess(float delta)
    {
        var new_anim = "idle";

	    if (state == State.Walking)
        {
            linear_velocity += GRAVITY_VEC * delta;
		    linear_velocity.x = direction * WALK_SPEED;
		    linear_velocity = MoveAndSlide(linear_velocity, FLOOR_NORMAL);

		    if (!detect_floor_left.IsColliding() || detect_wall_left.IsColliding())
			    direction = 1;

		    if (!detect_floor_right.IsColliding() || detect_wall_right.IsColliding())
			    direction = -1;

		    sprite.Scale = new Vector2(direction, 1);
		    new_anim = "walk";
        }
	    else
        {
            new_anim = "explode";
        }

	    if (anim != new_anim)
        {
		    anim = new_anim;
		    GetNode<AnimationPlayer>("anim").Play(anim);
        }
    }

    public void HitByBullet()
    {
        state = State.Killed;
    }
}

