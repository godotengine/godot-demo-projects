using Godot;
using System;

public partial class Pong : Node2D
{
    [Signal]
    public delegate void GameFinishedEventHandler(string withError);

    private const int ScoreToWin = 3;

    private int _scoreLeft = 0;
    private int _scoreRight = 0;
    private Paddle _playerTwo;
    private Label _scoreLeftNode;
    private Label _scoreRightNode;
    private Label _winnerLeft;
    private Label _winnerRight;

    public override void _Ready()
    {
        // Get nodes. The generic is the class, argument is path to the node.
        _playerTwo = GetNode<Paddle>("Player2");
        _scoreLeftNode = GetNode<Label>("ScoreLeft");
        _scoreRightNode = GetNode<Label>("ScoreRight");
        _winnerLeft = GetNode<Label>("WinnerLeft");
        _winnerRight = GetNode<Label>("WinnerRight");

        // By default, all nodes in server inherit from master,
        // while all nodes in clients inherit from puppet.
        // SetNetworkMaster is tree-recursive by default.
        if (GetTree().GetMultiplayer().IsServer())
        {
            _playerTwo.SetMultiplayerAuthority(GetTree().GetMultiplayer().GetPeers()[0]);
        }
        else
        {
            _playerTwo.SetMultiplayerAuthority(GetTree().GetMultiplayer().GetUniqueId());
        }

        GD.Print("Unique id: ", GetTree().GetMultiplayer().GetUniqueId());
    }

    [Rpc(CallLocal = true)]
    private void UpdateScore(bool addToLeft)
    {
        if (addToLeft)
        {
            _scoreLeft += 1;
            _scoreLeftNode.Text = _scoreLeft.ToString();
        }
        else
        {
            _scoreRight += 1;
            _scoreRightNode.Text = _scoreRight.ToString();
        }

        var gameEnded = false;

        if (_scoreLeft == ScoreToWin)
        {
            _winnerLeft.Show();
            gameEnded = true;
        }
        else if (_scoreRight == ScoreToWin)
        {
            _winnerRight.Show();
            gameEnded = true;
        }

        if (gameEnded)
        {
            GetNode<Button>("ExitGame").Show();
            GetNode<Ball>("Ball").Rpc("Stop");
        }
    }

    private void OnExitGamePressed()
    {
        EmitSignal(nameof(GameFinished), "");
    }
}
