using Godot;

public class Player : KinematicBody2D
{
    readonly Vector2 GRAVITY_VEC = new Vector2(0, 900);
    readonly Vector2 FLOOR_NORMAL = new Vector2(0, -1);
    const float MIN_ONAIR_TIME = 0.1f;
    const float WALK_SPEED = 250; // pixels/sec
    const float JUMP_SPEED = 480;
    const float SIDING_CHANGE_SPEED = 10;
    const float BULLET_VELOCITY = 1000;
    const float SHOOT_TIME_SHOW_WEAPON = 0.2f;

    Vector2 linear_vel = Vector2.Zero;
    float onair_time = 0;
    bool on_floor = false;
    float shoot_time = 99999; //time since last shot

    string anim = "";

    // cache the sprite here for fast access
    Sprite sprite;

    public override void _Ready()
    {
        base._Ready();

        sprite = GetNode<Sprite>("sprite");
    }

    public override void _PhysicsProcess(float delta)
    {
        // increment counters
	    onair_time += delta;
	    shoot_time += delta;        

        /// MOVEMENT ///

	    // Apply Gravity
	    linear_vel += delta * GRAVITY_VEC;
	    // Move and Slide
	    linear_vel = MoveAndSlide(linear_vel, floorNormal: FLOOR_NORMAL);
	    // Detect Floor
	    if (IsOnFloor())
            onair_time = 0;

	    on_floor = onair_time < MIN_ONAIR_TIME;

	    /// CONTROL ///

	    // Horizontal Movement
	    float target_speed = 0;
	    if (Input.IsActionPressed("move_left"))
		    target_speed += -1;
	    if (Input.IsActionPressed("move_right"))
		    target_speed +=  1;

	    target_speed *= WALK_SPEED;
	    linear_vel.x = Mathf.Lerp(linear_vel.x, target_speed, 0.1f);

	    // Jumping
	    if (on_floor && Input.IsActionJustPressed("jump"))
        {
            linear_vel.y = -JUMP_SPEED;
		    GetNode<AudioStreamPlayer2D>("sound_jump").Play();
        }

	    // Shooting
	    if (Input.IsActionJustPressed("shoot"))
        {
            RigidBody2D bullet = (RigidBody2D)((PackedScene)ResourceLoader.Load("res://bullet.tscn")).Instance();
		    bullet.Position = GetNode<Node2D>("sprite/bullet_shoot").GlobalPosition; // use node for shoot position
		    bullet.LinearVelocity = new Vector2(sprite.Scale.x * BULLET_VELOCITY, 0);
		    bullet.AddCollisionExceptionWith(this); // don't want player to collide with bullet
		    GetParent().AddChild(bullet); // don't want bullet to move with me, so add it as child of parent
		    GetNode<AudioStreamPlayer2D>("sound_shoot").Play();
		    shoot_time = 0;
        }
		    

	    /// ANIMATION ///

	    string new_anim = "idle";

	    if (on_floor)
        {
            if (linear_vel.x < -SIDING_CHANGE_SPEED)
            {
                sprite.Scale = new Vector2(-1, 1);
                new_anim = "run";
            }

            if (linear_vel.x > SIDING_CHANGE_SPEED)
            {
                sprite.Scale = new Vector2(1, 1);
                new_anim = "run";
            }
        }
        else
        {
            // We want the character to immediately change facing side when the player
		    // tries to change direction, during air control.
		    // This allows for example the player to shoot quickly left then right.
		    if (Input.IsActionPressed("move_left") && !Input.IsActionPressed("move_right"))
			    sprite.Scale = new Vector2(-1, 1);
		    if (Input.IsActionPressed("move_right") && !Input.IsActionPressed("move_left"))
			    sprite.Scale = new Vector2(1, 1);

		    if (linear_vel.y < 0)
			    new_anim = "jumping";
		    else
			    new_anim = "falling";
        }


	    if (shoot_time < SHOOT_TIME_SHOW_WEAPON)
		    new_anim += "_weapon";

	    if (new_anim != anim)
        {
            anim = new_anim;
            GetNode<AnimationPlayer>("anim").Play(anim);
        }
    }
}

