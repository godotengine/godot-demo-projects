using Godot;
using System;

public partial class Rock : CharacterBody2D
{
    [Rpc(CallLocal = true, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
    private void Exploded(int byWho)
    {
        GetNode<Score>("../../Score").IncreaseScore(byWho);

        GetNode<AnimationPlayer>("AnimationPlayer").Play("explode");
    }
}
