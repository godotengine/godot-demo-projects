public class FloorContact
{

    public bool FoundFloor { get; set; }
    public int FloorIndex { get; set; }

    public FloorContact(bool foundFloor, int floorIndex)
    {
        FoundFloor = false;
        FloorIndex = floorIndex;
    }

}
