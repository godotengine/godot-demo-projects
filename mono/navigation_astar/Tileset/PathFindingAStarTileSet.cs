using Godot;
using System.Collections.Generic;

public class PathFindingAStarTileSet : TileMap
{
    private const int ObstacleId = 0;
    private const int PathStartId = 1;
    private const int PathEndId = 2;
    private const int ClearCell = -1;
    private const float BaseLineWidth = 3.0f;
    private readonly Color DrawColor = new Color(0, 0, 0);

    [Export]
    private Vector2 _mapSize;

    private Vector2 _halfCellSize;
    private Vector2 _pathStartPosition;
    private Vector2 _pathEndPosition;
    private AStar2D _aStarNode;
    private List<Vector2> _cellPath;
    private List<Vector2> _obstacles;

    public override void _Ready()
    {
        _halfCellSize = CellSize / 2;
        _mapSize = new Vector2(16, 16);
        _aStarNode = new AStar2D();
        _cellPath = new List<Vector2>();
        _obstacles = new List<Vector2>();

        Godot.Collections.Array obstaclesArray = GetUsedCellsById(ObstacleId);
        for (int i = 0; i < obstaclesArray.Count; i++)
        {
            _obstacles.Add((Vector2)obstaclesArray[i]);
        }

        List<Vector2> walkableCells = CalculateAStarWalkableCells(_obstacles);
        ConnectAStarWalkableCells(walkableCells);
    }

    public override void _Draw()
    {
        if (_cellPath != null && _cellPath.Count != 0)
        {
            Vector2 startCell = _cellPath[0];
            Vector2 endCell = _cellPath[_cellPath.Count - 1];

            SetCell((int)startCell.x, (int)startCell.y, PathStartId);
            SetCell((int)endCell.x, (int)endCell.y, PathEndId);

            Vector2 lastCell = MapToWorld(new Vector2(startCell.x, startCell.y)) + _halfCellSize;

            for (int i = 1; i < _cellPath.Count; i++)
            {
                Vector2 currentCell = MapToWorld(new Vector2(_cellPath[i].x, _cellPath[i].y)) + _halfCellSize;
                DrawLine(lastCell, currentCell, DrawColor, BaseLineWidth, true);
                DrawCircle(currentCell, BaseLineWidth * 2.0f, DrawColor);

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
        foreach (Vector2 cell in _cellPath)
        {
            Vector2 cellWorld = MapToWorld(new Vector2(cell.x, cell.y)) + _halfCellSize;
            pathWorld.Add(cellWorld);
        }

        return pathWorld;
    }

    private List<Vector2> CalculateAStarWalkableCells(List<Vector2> obstacleCells)
    {
        List<Vector2> walkableCells = new List<Vector2>();
        for (int y = 0; y < _mapSize.y; y++)
        {
            for (int x = 0; x < _mapSize.x; x++)
            {
                Vector2 cell = new Vector2(x, y);

                if (!obstacleCells.Contains(cell))
                {
                    walkableCells.Add(cell);

                    int cellIndex = CalculateCellIndex(cell);
                    _aStarNode.AddPoint(cellIndex, new Vector2(cell.x, cell.y));
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

                if (!IsCellOutsideMapBounds(neighborCell) && _aStarNode.HasPoint(neighborCellIndex))
                {
                    _aStarNode.ConnectPoints(cellIndex, neighborCellIndex, false);
                }
            }
        }
    }

    private void ClearPreviousPathDrawing()
    {
        if (_cellPath != null && _cellPath.Count != 0)
        {
            Vector2 startCell = _cellPath[0];
            Vector2 endCell = _cellPath[_cellPath.Count - 1];

            SetCell((int)startCell.x, (int)startCell.y, ClearCell);
            SetCell((int)endCell.x, (int)endCell.y, ClearCell);
        }
    }

    private void RecalculatePath()
    {
        ClearPreviousPathDrawing();
        int startCellIndex = CalculateCellIndex(_pathStartPosition);
        int endCellIndex = CalculateCellIndex(_pathEndPosition);

        _cellPath.Clear();
        Vector2[] cellPathArray = _aStarNode.GetPointPath(startCellIndex, endCellIndex);
        for (int i = 0; i < cellPathArray.Length; i++)
        {
            _cellPath.Add(cellPathArray[i]);
        }

        Update();
    }

    private void ChangePathStartPosition(Vector2 newPathStartPosition)
    {
        if (!_obstacles.Contains(newPathStartPosition) && !IsCellOutsideMapBounds(newPathStartPosition))
        {
            SetCell((int)_pathStartPosition.x, (int)_pathStartPosition.y, ClearCell);
            SetCell((int)newPathStartPosition.x, (int)newPathStartPosition.y, PathStartId);
            _pathStartPosition = newPathStartPosition;

            if (_pathEndPosition == null && !_pathEndPosition.Equals(_pathStartPosition))
            {
                RecalculatePath();
            }
        }
    }

    private void ChangePathEndPosition(Vector2 newPathEndPosition)
    {
        if (!_obstacles.Contains(newPathEndPosition) && !IsCellOutsideMapBounds(newPathEndPosition))
        {
            SetCell((int)_pathStartPosition.x, (int)_pathStartPosition.y, ClearCell);
            SetCell((int)newPathEndPosition.x, (int)newPathEndPosition.y, PathEndId);
            _pathEndPosition = newPathEndPosition;

            if (!_pathStartPosition.Equals(newPathEndPosition))
            {
                RecalculatePath();
            }
        }
    }

    private int CalculateCellIndex(Vector2 cell)
    {
        return (int)(cell.x + _mapSize.x * cell.y);
    }

    private bool IsCellOutsideMapBounds(Vector2 cell)
    {
        return cell.x < 0 || cell.y < 0 || cell.x >= _mapSize.x || cell.y >= _mapSize.y;
    }
}
