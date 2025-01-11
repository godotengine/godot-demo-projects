using Godot;

public partial class ScoreLabel : Label
{
    private int _score = 0;

    public void OnMobSquashed()
    {
        _score += 1;
        Text = $"Score: {_score}";
    }
}
