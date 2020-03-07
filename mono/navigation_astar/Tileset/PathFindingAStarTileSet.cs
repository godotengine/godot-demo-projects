using Godot;
using System.Collections.Generic;

public class PathFindingAStarTileSet : TileMap
{

    private const int OBSTACLE_ID = 0;
    private const int PATH_START_ID = 1;
    private const int PATH_END_ID = 2;
    private const int CLEAR_CELL = -1;
    private const float BASE_LINE_WIDTH = 3.0f;
    private readonly Color DRAW_COLOR = new Color(0, 0, 0);

    [Export]
    private Vector2 mapSize;

    private Vector2 halfCellSize;
    private Vector2 pathStartPosition;
    private Vector2 pathEndPosition;
    private AStar2D aStarNode;
    private List<Vector2> cellPath;
    private List<Vector2> obstacles;

    public override void _Ready()
    {
        this.halfCellSize = this.CellSize / 2;
        this.mapSize = new Vector2(16, 16);
        this.aStarNode = new AStar2D();
        this.cellPath = new List<Vector2>();
        this.obstacles = new List<Vector2>();

        Godot.Collections.Array obstaclesArray = GetUsedCellsById(OBSTACLE_ID);
        for (int i = 0; i < obstaclesArray.Count; i++)
        {
            this.obstacles.Add((Vector2)obstaclesArray[i]);
        }

        List<Vector2> walkableCells = CalculateAStarWalkableCells(this.obstacles);
        ConnectAStarWalkableCells(walkableCells);
    }

    public override void _Draw()
    {
        if (this.cellPath != null && this.cellPath.Count != 0)
        {
            Vector2 startCell = this.cellPath[0];
            Vector2 endCell = this.cellPath[this.cellPath.Count - 1];

            SetCell((int)startCell.x, (int)startCell.y, PATH_START_ID);
            SetCell((int)endCell.x, (int)endCell.y, PATH_END_ID);

            Vector2 lastCell = MapToWorld(new Vector2(startCell.x, startCell.y)) + this.halfCellSize;

            for (int i = 1; i < this.cellPath.Count; i++)
            {
                Vector2 currentCell = MapToWorld(new Vector2(this.cellPath[i].x, this.cellPath[i].y)) + this.halfCellSize;
                DrawLine(lastCell, currentCell, DRAW_COLOR, BASE_LINE_WIDTH, true);
                DrawCircle(currentCell, BASE_LINE_WIDTH * 2.0f, DRAW_COLOR);

                lastCell = currentCell;
            }
        }
    }

    public List<Vector2> GetPath(Vector2 startCell, Vector2 endCell)
    {
        ChangePathStartPosition(WorldToMap(startCell));
        ChangePathEndPosition(WorldToMap(endCell));
        RecalculatePath();

        List<Vector2> pathWorld = new List<Vector2>();
        foreach (Vector2 cell in this.cellPath)
        {
            Vector2 cellWorld = MapToWorld(new Vector2(cell.x, cell.y)) + this.halfCellSize;
            pathWorld.Add(cellWorld);
        }

        return pathWorld;
    }

    private List<Vector2> CalculateAStarWalkableCells(List<Vector2> obstacleCells)
    {
        List<Vector2> walkableCells = new List<Vector2>();
        for (int y = 0; y < this.mapSize.y; y++)
        {
            for (int x = 0; x < this.mapSize.x; x++)
            {
                Vector2 cell = new Vector2(x, y);

                if (!obstacleCells.Contains(cell))
                {
                    walkableCells.Add(cell);

                    int cellIndex = CalculateCellIndex(cell);
                    aStarNode.AddPoint(cellIndex, new Vector2(cell.x, cell.y));
                }
            }
        }

        return walkableCells;
    }

    private void ConnectAStarWalkableCells(List<Vector2> walkableCells)
    {
        foreach (Vector2 cell in walkableCells)
        {
            int cellIndex = CalculateCellIndex(cell);

            List<Vector2> neighborCells = new List<Vector2>();
            neighborCells.Add(new Vector2(cell.x + 1, cell.y));
            neighborCells.Add(new Vector2(cell.x - 1, cell.y));
            neighborCells.Add(new Vector2(cell.x, cell.y + 1));
            neighborCells.Add(new Vector2(cell.x, cell.y - 1));

            foreach (Vector2 neighborCell in neighborCells)
            {
                int neighborCellIndex = CalculateCellIndex(neighborCell);

                if (!IsCellOutsideMapBounds(neighborCell) && this.aStarNode.HasPoint(neighborCellIndex))
                {
                    this.aStarNode.ConnectPoints(cellIndex, neighborCellIndex, false);
                }
            }
        }
    }

    private void ClearPreviousPathDrawing()
    {
        if (this.cellPath != null && this.cellPath.Count != 0)
        {
            Vector2 startCell = this.cellPath[0];
            Vector2 endCell = this.cellPath[this.cellPath.Count - 1];

            SetCell((int)startCell.x, (int)startCell.y, CLEAR_CELL);
            SetCell((int)endCell.x, (int)endCell.y, CLEAR_CELL);
        }
    }

    private void RecalculatePath()
    {
        ClearPreviousPathDrawing();
        int startCellIndex = CalculateCellIndex(this.pathStartPosition);
        int endCellIndex = CalculateCellIndex(this.pathEndPosition);

        this.cellPath.Clear();
        Vector2[] cellPathArray = this.aStarNode.GetPointPath(startCellIndex, endCellIndex);
        for (int i = 0; i < cellPathArray.Length; i++)
        {
            this.cellPath.Add(cellPathArray[i]);
        }

        Update();
    }

    private void ChangePathStartPosition(Vector2 newPathStartPosition)
    {
        if (!this.obstacles.Contains(newPathStartPosition) && !IsCellOutsideMapBounds(newPathStartPosition))
        {
            SetCell((int)this.pathStartPosition.x, (int)this.pathStartPosition.y, CLEAR_CELL);
            SetCell((int)newPathStartPosition.x, (int)newPathStartPosition.y, PATH_START_ID);
            this.pathStartPosition = newPathStartPosition;

            if (this.pathEndPosition == null && !this.pathEndPosition.Equals(this.pathStartPosition))
            {
                RecalculatePath();
            }
        }
    }

    private void ChangePathEndPosition(Vector2 newPathEndPosition)
    {
        if (!this.obstacles.Contains(newPathEndPosition) && !IsCellOutsideMapBounds(newPathEndPosition))
        {
            SetCell((int)this.pathStartPosition.x, (int)this.pathStartPosition.y, CLEAR_CELL);
            SetCell((int)newPathEndPosition.x, (int)newPathEndPosition.y, PATH_END_ID);
            this.pathEndPosition = newPathEndPosition;

            if (!this.pathStartPosition.Equals(newPathEndPosition))
            {
                RecalculatePath();
            }
        }
    }

    private int CalculateCellIndex(Vector2 cell)
    {
        return (int)(cell.x + this.mapSize.x * cell.y);
    }

    private bool IsCellOutsideMapBounds(Vector2 cell)
    {
        return cell.x < 0 || cell.y < 0 || cell.x >= this.mapSize.x || cell.y >= this.mapSize.y;
    }

}
