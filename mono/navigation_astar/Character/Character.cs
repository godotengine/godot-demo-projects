using Godot;
using System.Collections.Generic;

public class Character : Position2D
{

    private const float DEFAULT_SPEED = 200.0f;
    private const float MASS = 10.0f;
    private const float ARRIVE_DISTANCE = 10.0f;
    private const int NEXT_POSITION_INDEX = 0;
    private const int NO_MORE_PATHS = 0;

    [Export]
    private float speed = DEFAULT_SPEED;

    private CharacterState state;
    private List<Vector2> path;
    private Vector2 targetPointWorld;
    private Vector2 targetPosition;
    private Vector2 velocity;

    public override void _Ready()
    {
        this.path = new List<Vector2>();
        this.targetPointWorld = new Vector2();
        this.targetPosition = new Vector2();
        this.velocity = new Vector2();

        ChangeState(CharacterState.IDLE);
    }

    public override void _Process(float delta)
    {
        if (state.Equals(CharacterState.FOLLOW))
        {
            MoveTo(this.targetPointWorld);

            if (ArrivedTo(this.targetPointWorld))
            {
                this.path.RemoveAt(NEXT_POSITION_INDEX);

                if (this.path.Count == NO_MORE_PATHS)
                {
                    ChangeState(CharacterState.IDLE);
                    return;
                }

                this.targetPointWorld = path[NEXT_POSITION_INDEX];
            }
        }
    }

    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionPressed("click"))
        {
            Vector2 globalMousePosition = GetGlobalMousePosition();
            if (Input.IsKeyPressed((int)KeyList.Shift))
            {
                this.GlobalPosition = globalMousePosition;
            }
            else
            {
                this.targetPosition = globalMousePosition;
            }

            ChangeState(CharacterState.FOLLOW);
        }
    }

    private void ChangeState(CharacterState newState)
    {
        if (newState.Equals(CharacterState.FOLLOW))
        {
            PathFindingAStarTileSet tileMap = GetParent().GetNode("TileMap") as PathFindingAStarTileSet;
            this.path = tileMap.GetPath(this.Position, this.targetPosition);

            if (path == null || path.Count == 1)
            {
                ChangeState(CharacterState.IDLE);
                return;
            }

            this.targetPointWorld = path[1];
        }
        this.state = newState;
    }

    private void MoveTo(Vector2 destination)
    {
        Vector2 desiredVelocity = (destination - this.Position).Normalized() * this.speed;
        Vector2 steering = desiredVelocity - this.velocity;
        this.velocity += steering / MASS;
        this.Position += this.velocity * GetProcessDeltaTime();
        this.Rotation = this.velocity.Angle();
    }

    private bool ArrivedTo(Vector2 destination)
    {
        return this.Position.DistanceTo(destination) < ARRIVE_DISTANCE;
    }

}
