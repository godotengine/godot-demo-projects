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
        MoveLeft = moveLeft;
        MoveRight = moveRight;
        MoveForward = moveForward;
        MoveBackWards = moveBackwards;
        ResetPosition = resetPosition;
        Jump = jump;
    }
}
