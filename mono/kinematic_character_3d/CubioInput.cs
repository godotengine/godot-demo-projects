public class CubioInput
{

    public bool MoveLeft { get; set; }
    public bool MoveRight { get; set; }
    public bool MoveForward { get; set; }
    public bool MoveBackWards { get; set; }
    public bool ResetPosition { get; set; }
    public bool Jump { get; set; }


    public CubioInput(bool moveLeft, bool moveRight, bool moveForward, bool moveBackwards, bool resetPosition, bool jump)
    {
        this.MoveLeft = moveLeft;
        this.MoveRight = moveRight;
        this.MoveForward = moveForward;
        this.MoveBackWards = moveBackwards;
        this.ResetPosition = resetPosition;
        this.Jump = jump;
    }

}
