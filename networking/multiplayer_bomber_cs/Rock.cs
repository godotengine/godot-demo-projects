using Godot;
using System;

public partial class Rock : CharacterBody2D
{
    [Rpc(CallLocal = true, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
    private void exploded(int byWho)
    {
        GetNode("../../Score").Call("increase_score", byWho);

        GetNode("AnimationPlayer").Call("play", "explode");
    }
}
