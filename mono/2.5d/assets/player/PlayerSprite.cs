using Godot;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

[Tool]
public partial class PlayerSprite : Sprite2D
{
    private static Texture2D _stand = ResourceLoader.Load<Texture2D>("res://assets/player/textures/stand.png");
    private static Texture2D _jump = ResourceLoader.Load<Texture2D>("res://assets/player/textures/jump.png");
    private static Texture2D _run = ResourceLoader.Load<Texture2D>("res://assets/player/textures/run.png");
    private const int FRAMERATE = 15;

    private int _direction;
    private float _progress;
    private Node25D _parent;
    private PlayerMath25D _parentMath;

    public override void _Ready()
    {
        _parent = GetParent<Node25D>();
        _parentMath = _parent.GetChild<PlayerMath25D>(0);
    }

    public override void _Process(real_t delta)
    {
	    if (Engine.EditorHint)
        {
		    return; // Don't run this in the editor.
        }
        SpriteBasis();
        bool movement = CheckMovement(); // Always run to get direction, but don't always use return bool.

        // Test-only move and collide, check if the player is on the ground.
        var k = _parentMath.MoveAndCollide(Vector3.Down * 10 * delta, true, true, true);
        if (k != null)
        {
            if (movement)
            {
                // TODO: https://github.com/godotengine/godot/issues/28748
                Hframes = 6;
                Texture = _run;
                if (Input.IsActionPressed("movement_modifier"))
                {
                    delta /= 2;
                }
                _progress = (_progress + FRAMERATE * delta) % 6;
                Frame = _direction * 6 + (int)_progress;
            }
            else
            {
                Hframes = 1;
                Texture = _stand;
                _progress = 0;
                Frame = _direction;
            }
        }
        else
        {
            Hframes = 2;
            Texture = _jump;
            _progress = 0;
            int jumping = _parentMath.verticalSpeed < 0 ? 1 : 0;
            Frame = _direction * 2 + jumping;
        }
    }

    public void SetViewMode(int viewModeIndex)
    {
        Transform2D t = Transform;
        switch (viewModeIndex)
        {
            case 0:
                t.x = new Vector2(1, 0);
                t.y = new Vector2(0, 0.75f);
                break;
            case 1:
                t.x = new Vector2(1, 0);
                t.y = new Vector2(0, 1);
                break;
            case 2:
                t.x = new Vector2(1, 0);
                t.y = new Vector2(0, 0.5f);
                break;
            case 3:
                t.x = new Vector2(1, 0);
                t.y = new Vector2(0, 1);
                break;
            case 4:
                t.x = new Vector2(1, 0);
                t.y = new Vector2(0.75f, 0.75f);
                break;
            case 5:
                t.x = new Vector2(1, 0.25f);
                t.y = new Vector2(0, 1);
                break;
        }
        Transform = t;
    }

    /// <summary>
    /// Change the basis of the sprite to try and make it fit multiple view modes.
    /// </summary>
    private void SpriteBasis()
    {
        if (!Engine.EditorHint)
        {
            if (Input.IsActionPressed("forty_five_mode"))
            {
                SetViewMode(0);
            }
            else if (Input.IsActionPressed("isometric_mode"))
            {
                SetViewMode(1);
            }
            else if (Input.IsActionPressed("top_down_mode"))
            {
                SetViewMode(2);
            }
            else if (Input.IsActionPressed("front_side_mode"))
            {
                SetViewMode(3);
            }
            else if (Input.IsActionPressed("oblique_y_mode"))
            {
                SetViewMode(4);
            }
            else if (Input.IsActionPressed("oblique_z_mode"))
            {
                SetViewMode(5);
            }
        }
    }

    // There might be a more efficient way to do this, but I can't think of it.
    private bool CheckMovement()
    {
        // Gather player input and store movement to these int variables. Note: These indeed have to be integers.
        int x = 0;
        int z = 0;

        if (Input.IsActionPressed("move_right"))
        {
            x++;
        }
        if (Input.IsActionPressed("move_left"))
        {
            x--;
        }
        if (Input.IsActionPressed("move_forward"))
        {
            z--;
        }
        if (Input.IsActionPressed("move_back"))
        {
            z++;
        }

        // Check for isometric controls and add more to movement accordingly.
        // For efficiency, only check the X axis since this X axis value isn't used anywhere else.
        if (!_parentMath.isometricControls && _parent.Basis25D.x.IsEqualApprox(Basis25D.Isometric.x * Node25D.SCALE))
        {
            if (Input.IsActionPressed("move_right"))
            {
                z++;
            }
            if (Input.IsActionPressed("move_left"))
            {
                z--;
            }
            if (Input.IsActionPressed("move_forward"))
            {
                x++;
            }
            if (Input.IsActionPressed("move_back"))
            {
                x--;
            }
        }

        // Set the direction based on which inputs were pressed.
        if (x == 0)
        {
            if (z == 0)
            {
                return false; // No movement
            }
            else if (z > 0)
            {
                _direction = 0;
            }
            else
            {
                _direction = 4;
            }
        }
        else if (x > 0)
        {
            if (z == 0)
            {
                _direction = 2;
                FlipH = true;
            }
            else if (z > 0)
            {
                _direction = 1;
                FlipH = true;
            }
            else
            {
                _direction = 3;
                FlipH = true;
            }
        }
        else
        {
            if (z == 0)
            {
                _direction = 2;
                FlipH = false;
            }
            else if (z > 0)
            {
                _direction = 1;
                FlipH = false;
            }
            else
            {
                _direction = 3;
                FlipH = false;
            }
        }
        return true; // There is movement
    }
}
