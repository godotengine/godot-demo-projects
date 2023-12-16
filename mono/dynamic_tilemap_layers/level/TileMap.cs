using Godot;

public partial class TileMap : Godot.TileMap
{
    // You can have multiple layers if you make _secretLayer an array.
    private int _secretLayer;
    private bool _playerInSecret;
    private double _layerAlpha = 1.0;

    public TileMap()
    {
        // Find the secret layer by name.
        for (int i = 0; i < GetLayersCount(); i++)
        {
            if (GetLayerName(i) == "Secret")
            {
                _secretLayer = i;
            }
        }
    }

    public override void _Ready()
    {
        SetProcess(false);
    }

    public override void _Process(double delta)
    {
        if (_playerInSecret)
        {
            if (_layerAlpha > 0.3)
            {
                // Animate the layer transparency.
                _layerAlpha = Mathf.MoveToward(_layerAlpha, 0.3, delta);
                SetLayerModulate(_secretLayer, new Color(1, 1, 1, (float)_layerAlpha));
            }
            else
            {
                SetProcess(false);
            }
        }
        else
        {
            if (_layerAlpha < 1.0)
            {
                _layerAlpha = Mathf.MoveToward(_layerAlpha, 1.0, delta);
                SetLayerModulate(_secretLayer, new Color(1, 1, 1, (float)_layerAlpha));
            }
            else
            {
                SetProcess(false);
            }
        }
    }

    public override bool _UseTileDataRuntimeUpdate(int layer, Vector2I coords)
    {
        if (layer == _secretLayer)
        {
            return true;
        }

        return false;
    }

    public override void _TileDataRuntimeUpdate(int layer, Vector2I coords, TileData tileData)
    {
        // Remove collision for secret layer.
        tileData.SetCollisionPolygonsCount(0, 0);
    }

    private void OnSecretDetectorBodyEntered(Node2D body)
    {
        // Detect player only.
        if (body is not CharacterBody2D)
        {
            return;
        }

        _playerInSecret = true;
        SetProcess(true);
    }

    public void OnSecretDetectorBodyExited(Node2D body)
    {
        if (body is not CharacterBody2D)
        {
            return;
        }

        _playerInSecret = false;
        SetProcess(true);
    }
}
