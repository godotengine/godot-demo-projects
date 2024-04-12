using Godot;

public partial class HUD : CanvasLayer
{
    [Signal]
    public delegate void StartGameEventHandler();

    public void ShowMessage(string text)
    {
        var messageLabel = GetNode<Label>("MessageLabel");
        messageLabel.Text = text;
        messageLabel.Show();

        GetNode<Timer>("MessageTimer").Start();
    }

    public async void ShowGameOver()
    {
        ShowMessage("Game Over");

        var messageTimer = GetNode<Timer>("MessageTimer");
        await ToSignal(messageTimer, Timer.SignalName.Timeout);

        ShowMessage("Dodge the\nCreeps!");
        await ToSignal(GetTree().CreateTimer(1.0), SceneTreeTimer.SignalName.Timeout);

        GetNode<Button>("StartButton").Show();
    }

    public void UpdateScore(int score)
    {
        GetNode<Label>("ScoreLabel").Text = score.ToString();
    }

    public void OnStartButtonPressed()
    {
        GetNode<Button>("StartButton").Hide();
        EmitSignal(SignalName.StartGame);
    }

    public void OnMessageTimerTimeout()
    {
        GetNode<Label>("MessageLabel").Hide();
    }
}
