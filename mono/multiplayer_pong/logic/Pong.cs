using Godot;
using System;

public class Pong : Node2D
{
    [Signal]
    private delegate void GameFinished(string withError);

    private const int ScoreToWin = 10;

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
        if (GetTree().IsNetworkServer())
        {
            _playerTwo.SetNetworkMaster(GetTree().GetNetworkConnectedPeers()[0]);
        }
        else
        {
            _playerTwo.SetNetworkMaster(GetTree().GetNetworkUniqueId());
        }

        GD.Print("Unique id: ", GetTree().GetNetworkUniqueId());
    }

    [Sync]
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
