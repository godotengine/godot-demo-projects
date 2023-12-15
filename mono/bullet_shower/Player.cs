using Godot;

public partial class Player : Area2D
{
    private int _touching = 0;
    private AnimatedSprite2D _sprite;

    public override void _Ready()
    {
        _sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");

        // The player follows the mouse cursor automatically, so there's no point
        // in displaying the mouse cursor.
        Input.MouseMode = Input.MouseModeEnum.Hidden;
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        // Getting the movement of the mouse so the sprite can follow its position.
        if (@event is InputEventMouseMotion mouseMotion)
        {
            Position = mouseMotion.Position - new Vector2(0, 16);
        }
    }

    private void OnBodyShapeEntered(Rid _bodyRid, Node2D _body, int _bodyShapeIndex, int _localShapeIndex)
    {
        // Player got touched by a bullet so sprite changes to sad face.
        _touching += 1;
        if (_touching >= 1)
        {
            _sprite.Frame = 1;
        }
    }

    private void OnBodyShapeExited(Rid _bodyRid, Node2D _body, int _bodyShapeIndex, int _localShapeIndex)
    {
        _touching -= 1;
        // When non of the bullets are touching the player,
        // sprite changes to happy face.
        if (_touching == 0)
        {
            _sprite.Frame = 0;
        }
    }
}
